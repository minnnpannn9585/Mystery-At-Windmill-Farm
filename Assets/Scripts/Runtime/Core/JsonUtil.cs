using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace EggRescue
{
    public sealed class JsonValue
    {
        public enum Kind
        {
            Null,
            Bool,
            Number,
            String,
            Array,
            Object
        }

        public Kind Type { get; private set; }
        public bool BoolValue;
        public double NumberValue;
        public string StringValue;
        public List<JsonValue> ArrayValue;
        public Dictionary<string, JsonValue> ObjectValue;

        public static JsonValue Null = new JsonValue { Type = Kind.Null };
        public static JsonValue Parse(string json)
        {
            return new Parser(json ?? "null").ParseValue();
        }

        public bool IsNull { get { return Type == Kind.Null; } }

        public JsonValue this[string key]
        {
            get
            {
                JsonValue value;
                if (Type == Kind.Object && ObjectValue != null && ObjectValue.TryGetValue(key, out value))
                    return value;
                return Null;
            }
        }

        public JsonValue this[int index]
        {
            get
            {
                if (Type == Kind.Array && ArrayValue != null && index >= 0 && index < ArrayValue.Count)
                    return ArrayValue[index];
                return Null;
            }
        }

        public int Count
        {
            get
            {
                if (Type == Kind.Array && ArrayValue != null) return ArrayValue.Count;
                if (Type == Kind.Object && ObjectValue != null) return ObjectValue.Count;
                return 0;
            }
        }

        public string AsString(string fallback = "")
        {
            if (Type == Kind.String) return StringValue ?? fallback;
            if (Type == Kind.Number) return NumberValue.ToString(CultureInfo.InvariantCulture);
            if (Type == Kind.Bool) return BoolValue ? "true" : "false";
            return fallback;
        }

        public int AsInt(int fallback = 0)
        {
            if (Type == Kind.Number) return (int)NumberValue;
            if (Type == Kind.String)
            {
                int n;
                if (int.TryParse(StringValue, NumberStyles.Integer, CultureInfo.InvariantCulture, out n))
                    return n;
            }
            if (Type == Kind.Bool) return BoolValue ? 1 : 0;
            return fallback;
        }

        public bool AsBool(bool fallback = false)
        {
            if (Type == Kind.Bool) return BoolValue;
            if (Type == Kind.Number) return NumberValue != 0;
            if (Type == Kind.String)
            {
                if (StringValue == "true" || StringValue == "1") return true;
                if (StringValue == "false" || StringValue == "0") return false;
            }
            return fallback;
        }

        public bool Has(string key)
        {
            return Type == Kind.Object && ObjectValue != null && ObjectValue.ContainsKey(key) && !ObjectValue[key].IsNull;
        }

        public IEnumerable<JsonValue> AsArray()
        {
            if (Type == Kind.Array && ArrayValue != null)
                return ArrayValue;
            if (Type == Kind.Object && ObjectValue != null)
            {
                var list = new List<JsonValue>();
                var i = 1;
                JsonValue item;
                while (ObjectValue.TryGetValue(i.ToString(CultureInfo.InvariantCulture), out item))
                {
                    list.Add(item);
                    i++;
                }
                if (list.Count > 0)
                    return list;
            }
            return Array.Empty<JsonValue>();
        }

        sealed class Parser
        {
            readonly string _src;
            int _i;

            public Parser(string src) { _src = src; }

            public JsonValue ParseValue()
            {
                Skip();
                if (_i >= _src.Length) return Null;
                var ch = _src[_i];
                if (ch == '{') return ParseObject();
                if (ch == '[') return ParseArray();
                if (ch == '"') return OfString(ParseString());
                if (ch == 't' || ch == 'f') return OfBool(ParseLiteralBool());
                if (ch == 'n') { ParseNull(); return Null; }
                return OfNumber(ParseNumber());
            }

            JsonValue ParseObject()
            {
                _i++;
                var obj = new Dictionary<string, JsonValue>();
                Skip();
                if (Peek() == '}') { _i++; return OfObject(obj); }
                while (true)
                {
                    Skip();
                    var key = ParseString();
                    Skip();
                    Expect(':');
                    var val = ParseValue();
                    obj[key] = val;
                    Skip();
                    if (Peek() == ',') { _i++; continue; }
                    Expect('}');
                    break;
                }
                return OfObject(obj);
            }

            JsonValue ParseArray()
            {
                _i++;
                var arr = new List<JsonValue>();
                Skip();
                if (Peek() == ']') { _i++; return OfArray(arr); }
                while (true)
                {
                    arr.Add(ParseValue());
                    Skip();
                    if (Peek() == ',') { _i++; continue; }
                    Expect(']');
                    break;
                }
                return OfArray(arr);
            }

            string ParseString()
            {
                Expect('"');
                var sb = new StringBuilder();
                while (_i < _src.Length)
                {
                    var ch = _src[_i++];
                    if (ch == '"') break;
                    if (ch == '\\' && _i < _src.Length)
                    {
                        var nxt = _src[_i++];
                        switch (nxt)
                        {
                            case 'n': sb.Append('\n'); break;
                            case 'r': sb.Append('\r'); break;
                            case 't': sb.Append('\t'); break;
                            case '"': sb.Append('"'); break;
                            case '\\': sb.Append('\\'); break;
                            case 'u':
                                if (_i + 4 <= _src.Length)
                                {
                                    var hex = _src.Substring(_i, 4);
                                    _i += 4;
                                    int code;
                                    if (int.TryParse(hex, NumberStyles.HexNumber, CultureInfo.InvariantCulture, out code))
                                        sb.Append((char)code);
                                }
                                break;
                            default: sb.Append(nxt); break;
                        }
                    }
                    else sb.Append(ch);
                }
                return sb.ToString();
            }

            double ParseNumber()
            {
                var start = _i;
                if (Peek() == '-' || Peek() == '+') _i++;
                while (_i < _src.Length && (char.IsDigit(_src[_i]) || _src[_i] == '.' || _src[_i] == 'e' || _src[_i] == 'E' || _src[_i] == '+' || _src[_i] == '-'))
                {
                    if ((_src[_i] == '+' || _src[_i] == '-') && _i > start && _src[_i - 1] != 'e' && _src[_i - 1] != 'E')
                        break;
                    _i++;
                }
                double n;
                if (!double.TryParse(_src.Substring(start, _i - start), NumberStyles.Float, CultureInfo.InvariantCulture, out n))
                    n = 0;
                return n;
            }

            bool ParseLiteralBool()
            {
                if (Match("true")) return true;
                if (Match("false")) return false;
                throw new FormatException("invalid bool at " + _i);
            }

            void ParseNull()
            {
                if (!Match("null")) throw new FormatException("invalid null at " + _i);
            }

            bool Match(string s)
            {
                if (_i + s.Length > _src.Length) return false;
                if (_src.Substring(_i, s.Length) != s) return false;
                _i += s.Length;
                return true;
            }

            void Skip()
            {
                while (_i < _src.Length && char.IsWhiteSpace(_src[_i])) _i++;
            }

            char Peek() { return _i < _src.Length ? _src[_i] : '\0'; }

            void Expect(char ch)
            {
                Skip();
                if (Peek() != ch) throw new FormatException("expected " + ch + " at " + _i);
                _i++;
            }
        }

        static JsonValue OfString(string s)
        {
            return new JsonValue { Type = Kind.String, StringValue = s };
        }

        static JsonValue OfNumber(double n)
        {
            return new JsonValue { Type = Kind.Number, NumberValue = n };
        }

        static JsonValue OfBool(bool b)
        {
            return new JsonValue { Type = Kind.Bool, BoolValue = b };
        }

        static JsonValue OfArray(List<JsonValue> arr)
        {
            return new JsonValue { Type = Kind.Array, ArrayValue = arr };
        }

        static JsonValue OfObject(Dictionary<string, JsonValue> obj)
        {
            return new JsonValue { Type = Kind.Object, ObjectValue = obj };
        }
    }
}
