(function (factory) {
    typeof define === 'function' && define.amd ? define(factory) :
        factory();
})((function () { 'use strict';

    let stringToUTF8;
    let lengthBytesUTF8;
    let UTF8ToString;
    let _malloc;
    let _free;
    let dynCall;
    let Module;
    function inject(wasm) {
        stringToUTF8 = wasm.stringToUTF8;
        lengthBytesUTF8 = wasm.lengthBytesUTF8;
        UTF8ToString = wasm.UTF8ToString;
        _malloc = wasm._malloc;
        _free = wasm._free;
        dynCall = wasm.dynCall;
        Module = wasm.Module;
    }
    function strToPtr(str) {
        const length = lengthBytesUTF8(str) + 1;
        const ptr = _malloc(length);
        stringToUTF8(str, ptr, length);
        return ptr;
    }
    function strFromPtr(ptr) {
        return UTF8ToString(ptr);
    }
    function u8ArrayToPtr(array, ptrOrNull) {
        const length = array.byteLength;
        const ptr = ptrOrNull || _malloc(length);
        Module.HEAPU8.set(array, ptr);
        return ptr;
    }
    function u8ArrayFromPtr(ptr, length, copy) {
        const array = Module.HEAPU8.subarray(ptr, ptr + length);
        if (copy) {
            return array.slice();
        }
        return array;
    }
    function makeDynCaller(sig, ptr, args) {
        return dynCall(sig, ptr, args);
    }
    function free(ptr) {
        _free(ptr);
    }
    const wasmUtils = {
        strToPtr,
        strFromPtr,
        u8ArrayToPtr,
        u8ArrayFromPtr,
        makeDynCaller,
        free,
        inject,
    };

    function writeImageBytesSync(dataPtr, length, typePtr) {
        // 将类型指针转换为 JS 字符串
        const imageType = wasmUtils.strFromPtr(typePtr);
        // 从 WASM 内存中截取并复制字节数组
        const array = wasmUtils.u8ArrayFromPtr(dataPtr, length, true);
        let resultPath;
        try {
            const result = __game_dock_extra__.innerGameApi.invokeBufferSync("hamletSaveImageSync", {
                data: array.buffer,
                type: imageType,
            });
            resultPath = result.path;
        }
        catch (e) {
            console.error("Error calling external API (hamletSaveImageSync):", e);
            resultPath = "";
        }
        const buffer = wasmUtils.strToPtr(resultPath); // 分配 WASM 内存
        return buffer; // 返回指向结果字符串的指针
    }

    /**
     * 同步读取本地文件
     * @param {number} filePathPtr - 文件路径指针 (UTF8 字符串)
     * @param {number} encodingPtr - 编码格式指针 (UTF8 字符串)，可选值：'utf8', 'binary', 'base64', null/undefined 表示返回 ArrayBuffer
     * @returns {number} - 返回指向结果结构体的指针，结构体格式：{ success: boolean, data: string|ArrayBuffer, error: string }
     * 注意：调用方需要释放返回的内存
     */
    function readFileSync(filePathPtr, encodingPtr) {
        const filePath = wasmUtils.strFromPtr(filePathPtr);
        const encoding = encodingPtr ? wasmUtils.strFromPtr(encodingPtr) : null;

        let result;
        try {
            const fs = gameApi.getFileSystemManager();
            const readResult = fs.readFileSync(filePath, encoding);
            result = {
                success: true,
                data: readResult instanceof ArrayBuffer ? btoa(String.fromCharCode(...new Uint8Array(readResult))) : readResult,
                error: null
            };
        } catch (e) {
            console.error("Error reading file:", e);
            result = {
                success: false,
                data: null,
                error: e.message || "Failed to read file"
            };
        }

        // 将结果序列化为 JSON 字符串返回
        const resultJson = JSON.stringify(result);
        return wasmUtils.strToPtr(resultJson);
    }

    /**
     * 异步读取本地文件
     * @param {number} filePathPtr - 文件路径指针 (UTF8 字符串)
     * @param {number} encodingPtr - 编码格式指针 (UTF8 字符串)，可选值：'utf8', 'binary', 'base64', null/undefined 表示返回 ArrayBuffer
     * @param {number} callbackPtr - 回调函数指针 (C# 回调)
     * @param {number} callbackId - 回调 ID，用于区分多个异步调用
     */
    function readFileAsync(filePathPtr, encodingPtr, callbackPtr, callbackId) {
        const filePath = wasmUtils.strFromPtr(filePathPtr);
        const encoding = encodingPtr ? wasmUtils.strFromPtr(encodingPtr) : null;

        const fs = gameApi.getFileSystemManager();
        fs.readFile({
            filePath: filePath,
            encoding: encoding,
            success: function(res) {
                if (res.data instanceof ArrayBuffer) {
                    // 直接将 ArrayBuffer 写入 WASM 内存
                    const bytes = new Uint8Array(res.data);
                    const dataPtr = _malloc(bytes.length);
                    Module.HEAPU8.set(bytes, dataPtr);
                    // 回调：callbackId, success=1, dataPtr, dataLength
                    wasmUtils.makeDynCaller('viiii', callbackPtr, [callbackId, 1, dataPtr, bytes.length]);
                    _free(dataPtr);
                } else {
                    // 文本数据，转为 UTF8 写入内存
                    const str = String(res.data);
                    const length = lengthBytesUTF8(str) + 1;
                    const dataPtr = _malloc(length);
                    stringToUTF8(str, dataPtr, length);
                    wasmUtils.makeDynCaller('viiii', callbackPtr, [callbackId, 1, dataPtr, length - 1]);
                    _free(dataPtr);
                }
            },
            fail: function(res) {
                console.error("readFileAsync failed:", res.errMsg);
                // 回调：callbackId, success=0, dataPtr=0, dataLength=0
                wasmUtils.makeDynCaller('viiii', callbackPtr, [callbackId, 0, 0, 0]);
            }
        });
        
    }

    /**
     * 检查文件/目录是否存在（同步）
     * @param {number} pathPtr - 路径指针 (UTF8 字符串)
     * @returns {number} - 存在返回 1，不存在或出错返回 0
     */
    function accessSync(pathPtr) {
        const path = wasmUtils.strFromPtr(pathPtr);
        try {
            const fs = gameApi.getFileSystemManager();
            fs.accessSync(path);
            return 1; // 存在
        } catch (e) {
            return 0; // 不存在或出错
        }
    }
    // jsblib 调用create后会将返回的对象挂到window的hamlet对象上。
    function createHamletBridge(wasm) {
        wasmUtils.inject(wasm);
        window.hamlet.didInit = true;
    }
    function hamletReportGameException(name, reason, stacktrace) {
        if (window.webkit &&
            window.webkit.messageHandlers &&
            window.webkit.messageHandlers.unityExceptionHandler) {
            window.webkit.messageHandlers.unityExceptionHandler.postMessage({
                name: name,
                reason: reason,
                stacktrace: stacktrace,
            });
        }
    }
    // 将这个工厂函数暴露给全局 window 对象，等待 JSLIB 调用
    window.hamlet = {
        createHamletBridge: createHamletBridge,
        reportGameException: hamletReportGameException,
        writeImageBytesSync: writeImageBytesSync,
        readFileSync: readFileSync,
        readFileAsync: readFileAsync,
        accessSync: accessSync,
        didInit: false,
    };

}));
