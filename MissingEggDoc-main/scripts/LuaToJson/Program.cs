using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

static class Program
{
    static int Main(string[] args)
    {
        var root = FindRepoRoot();
        var data = Path.Combine(root, "Assets", "Data");
        var output = Path.Combine(root, "Assets", "Resources", "GameData");
        Directory.CreateDirectory(output);
        Directory.CreateDirectory(Path.Combine(output, "Dialogue"));

        ConvertAssignment(Path.Combine(data, "GlobalData", "GlobalVariables.lua"), "GlobalVariables",
            Path.Combine(output, "global_variables.txt"));
        ConvertAssignment(Path.Combine(data, "GlobalData", "NPCData_Config.lua"), "NPCData",
            Path.Combine(output, "npc_data.txt"));

        ConvertDialogue(Path.Combine(data, "DialogueData", "miaosu.lua"), "miaosu", output);
        foreach (var path in Directory.GetFiles(Path.Combine(data, "DialogueData", "FROM_DOC"), "*_FROM_DOC.lua"))
            ConvertDialogue(path, Path.GetFileNameWithoutExtension(path), output);

        Console.WriteLine("done");
        return 0;
    }

    static string FindRepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "Assets", "Data", "GlobalData", "GlobalVariables.lua")))
                return dir.FullName;
            dir = dir.Parent;
        }

        var cwd = Directory.GetCurrentDirectory();
        if (File.Exists(Path.Combine(cwd, "Assets", "Data", "GlobalData", "GlobalVariables.lua")))
            return cwd;
        throw new DirectoryNotFoundException("Could not find repo root");
    }

    static void ConvertAssignment(string luaPath, string name, string jsonPath)
    {
        var node = LuaTableParser.ExtractAssignment(File.ReadAllText(luaPath), name);
        WriteJson(jsonPath, node);
        Console.WriteLine("wrote " + Path.GetFileName(jsonPath));
    }

    static void ConvertDialogue(string luaPath, string module, string outputRoot)
    {
        var table = LuaTableParser.ExtractIndexedTable(File.ReadAllText(luaPath), "DialogueConfig");
        var nodes = new JsonArray();
        if (table is JsonObject obj)
        {
            var ordered = obj
                .Where(kv => int.TryParse(kv.Key, out _))
                .Select(kv => (Id: int.Parse(kv.Key), Node: kv.Value as JsonObject))
                .Where(x => x.Node != null)
                .OrderBy(x => x.Id);
            foreach (var (id, node) in ordered)
            {
                node["id"] = id;
                nodes.Add(JsonNode.Parse(node.ToJsonString()));
            }
        }

        var wrapped = new JsonObject
        {
            ["module"] = module,
            ["nodes"] = nodes
        };
        var dest = Path.Combine(outputRoot, "Dialogue", module + ".txt");
        WriteJson(dest, wrapped);
        Console.WriteLine($"wrote Dialogue/{module}.txt ({nodes.Count} nodes)");
    }

    static void WriteJson(string path, JsonNode? node)
    {
        var json = node?.ToJsonString(new JsonSerializerOptions { WriteIndented = true }) ?? "null";
        File.WriteAllText(path, json, new UTF8Encoding(false));
    }
}

static class LuaTableParser
{
    public static JsonObject ExtractIndexedTable(string text, string name)
    {
        var stripped = StripComments(text);
        var marker = name + "[";
        var obj = new JsonObject();
        var idx = 0;
        while (true)
        {
            var found = stripped.IndexOf(marker, idx, StringComparison.Ordinal);
            if (found < 0) break;
            var lex = new Lexer(stripped[(found + marker.Length)..]);
            JsonNode? keyNode;
            try
            {
                keyNode = ParseValue(lex);
                if (lex.Peek() != ']')
                {
                    idx = found + marker.Length;
                    continue;
                }
                lex.Take();
                if (lex.Peek() != '=')
                {
                    idx = found + marker.Length;
                    continue;
                }
                lex.Take();
                var val = ParseValue(lex);
                var key = keyNode is JsonValue kv && kv.TryGetValue<long>(out var l)
                    ? l.ToString(CultureInfo.InvariantCulture)
                    : keyNode?.ToJsonString()?.Trim('"') ?? "";
                if (!string.IsNullOrEmpty(key))
                    obj[key] = val;
                idx = found + marker.Length + lex.I;
            }
            catch
            {
                idx = found + marker.Length;
            }
        }
        return obj;
    }

    public static JsonNode? ExtractAssignment(string text, string name)
    {
        var stripped = StripComments(text);
        var token = name + " =";
        var idx = stripped.IndexOf(token, StringComparison.Ordinal);
        if (idx < 0)
        {
            token = name + "=";
            idx = stripped.IndexOf(token, StringComparison.Ordinal);
        }
        if (idx < 0)
            throw new InvalidOperationException(name + " assignment not found");
        var lex = new Lexer(stripped[(idx + token.Length)..]);
        return ParseValue(lex);
    }

    static string StripComments(string text)
    {
        var sb = new StringBuilder(text.Length);
        var i = 0;
        while (i < text.Length)
        {
            if (i + 1 < text.Length && text[i] == '-' && text[i + 1] == '-')
            {
                if (i + 3 < text.Length && text[i + 2] == '[' && text[i + 3] == '[')
                {
                    var end = text.IndexOf("]]", i + 4, StringComparison.Ordinal);
                    i = end < 0 ? text.Length : end + 2;
                    continue;
                }
                while (i < text.Length && text[i] != '\n' && text[i] != '\r')
                    i++;
                continue;
            }
            if (text[i] == '"')
            {
                sb.Append(text[i++]);
                while (i < text.Length)
                {
                    var ch = text[i++];
                    sb.Append(ch);
                    if (ch == '\\' && i < text.Length)
                    {
                        sb.Append(text[i++]);
                        continue;
                    }
                    if (ch == '"')
                        break;
                }
                continue;
            }
            sb.Append(text[i++]);
        }
        return sb.ToString();
    }

    sealed class Lexer
    {
        public readonly string Src;
        public int I;
        public Lexer(string src) { Src = src; }

        public char Peek()
        {
            SkipWs();
            return I < Src.Length ? Src[I] : '\0';
        }

        public char Take()
        {
            SkipWs();
            return I < Src.Length ? Src[I++] : '\0';
        }

        public void SkipWs()
        {
            while (I < Src.Length && char.IsWhiteSpace(Src[I]))
                I++;
        }

        public string Ident()
        {
            SkipWs();
            var start = I;
            if (I < Src.Length && (char.IsLetter(Src[I]) || Src[I] == '_'))
            {
                I++;
                while (I < Src.Length && (char.IsLetterOrDigit(Src[I]) || Src[I] == '_'))
                    I++;
            }
            return Src[start..I];
        }

        public JsonNode Number()
        {
            SkipWs();
            var start = I;
            if (I < Src.Length && (Src[I] == '+' || Src[I] == '-'))
                I++;
            while (I < Src.Length && (char.IsDigit(Src[I]) || Src[I] is '.' or 'e' or 'E' or '+' or '-'))
            {
                if ((Src[I] == '+' || Src[I] == '-') && I > start && Src[I - 1] is not ('e' or 'E'))
                    break;
                I++;
            }
            var raw = Src[start..I];
            if (raw.Contains('.') || raw.Contains('e') || raw.Contains('E'))
                return JsonValue.Create(double.Parse(raw, CultureInfo.InvariantCulture));
            return JsonValue.Create(long.Parse(raw, CultureInfo.InvariantCulture));
        }

        public string String()
        {
            SkipWs();
            if (Take() != '"')
                throw new InvalidOperationException("expected string");
            var sb = new StringBuilder();
            while (I < Src.Length)
            {
                var ch = Src[I++];
                if (ch == '"')
                    break;
                if (ch == '\\' && I < Src.Length)
                {
                    var nxt = Src[I++];
                    sb.Append(nxt switch
                    {
                        'n' => '\n',
                        'r' => '\r',
                        't' => '\t',
                        '"' => '"',
                        '\\' => '\\',
                        _ => nxt
                    });
                }
                else
                    sb.Append(ch);
            }
            return sb.ToString();
        }
    }

    static JsonNode? ParseValue(Lexer lex)
    {
        var ch = lex.Peek();
        if (ch == '{')
            return ParseTable(lex);
        if (ch == '"')
            return JsonValue.Create(lex.String());
        if (ch is '+' or '-' || char.IsDigit(ch))
            return lex.Number();
        var ident = lex.Ident();
        return ident switch
        {
            "true" => JsonValue.Create(true),
            "false" => JsonValue.Create(false),
            "nil" => null,
            _ => throw new InvalidOperationException($"unexpected ident {ident} at {lex.I}")
        };
    }

    static JsonNode ParseTable(Lexer lex)
    {
        if (lex.Take() != '{')
            throw new InvalidOperationException("expected {");
        var obj = new JsonObject();
        var arr = new JsonArray();
        var isArray = true;
        var nextIndex = 1L;
        while (true)
        {
            var ch = lex.Peek();
            if (ch == '}')
            {
                lex.Take();
                break;
            }
            if (ch == '\0')
                throw new InvalidOperationException("unterminated table");

            JsonNode? keyNode = null;
            JsonNode? val;
            if (ch == '[')
            {
                lex.Take();
                keyNode = ParseValue(lex);
                if (lex.Peek() != ']')
                    throw new InvalidOperationException("expected ]");
                lex.Take();
                if (lex.Peek() != '=')
                    throw new InvalidOperationException("expected = after [] key");
                lex.Take();
                val = ParseValue(lex);
            }
            else
            {
                var save = lex.I;
                var ident = lex.Ident();
                if (!string.IsNullOrEmpty(ident) && lex.Peek() == '=')
                {
                    lex.Take();
                    keyNode = JsonValue.Create(ident);
                    val = ParseValue(lex);
                }
                else
                {
                    lex.I = save;
                    val = ParseValue(lex);
                    keyNode = JsonValue.Create(nextIndex);
                    nextIndex++;
                }
            }

            long? intKey = null;
            if (keyNode is JsonValue kv)
            {
                if (kv.TryGetValue<long>(out var l))
                    intKey = l;
                else if (kv.TryGetValue<string>(out var s) && long.TryParse(s, out var parsed))
                    intKey = parsed;
            }

            if (intKey is long ik && isArray && ik == arr.Count + 1)
            {
                arr.Add(val);
            }
            else
            {
                isArray = false;
                var key = intKey?.ToString(CultureInfo.InvariantCulture)
                          ?? keyNode?.GetValue<string>()
                          ?? keyNode?.ToJsonString()
                          ?? nextIndex.ToString(CultureInfo.InvariantCulture);
                obj[key] = val;
            }

            ch = lex.Peek();
            if (ch == ',')
            {
                lex.Take();
                continue;
            }
            if (ch == '}')
            {
                lex.Take();
                break;
            }
            throw new InvalidOperationException($"expected , or }} at {lex.I}, got {ch}");
        }

        if (obj.Count > 0 && arr.Count > 0)
        {
            for (var i = 0; i < arr.Count; i++)
            {
                var k = (i + 1).ToString(CultureInfo.InvariantCulture);
                if (!obj.ContainsKey(k))
                    obj[k] = arr[i];
            }
            return obj;
        }
        if (obj.Count > 0)
            return obj;
        return arr;
    }
}
