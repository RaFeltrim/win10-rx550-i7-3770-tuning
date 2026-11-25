using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

class GpuBench {
    // --- ADL ---
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate IntPtr ADL_MAIN_MALLOC_CALLBACK(int size);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Main_Control_Create(ADL_MAIN_MALLOC_CALLBACK callback, int enumConnectedAdapters);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Main_Control_Destroy();

    [StructLayout(LayoutKind.Sequential)]
    struct ADLTemperature { public int iSize; public int iTemperature; }

    [StructLayout(LayoutKind.Sequential)]
    struct ADLPMActivity {
        public int iSize, iEngineClock, iMemoryClock, iVddc, iActivityPercent,
                   iCurrentPerformanceLevel, iCurrentBusSpeed, iCurrentBusLanes, iMaximumBusLanes, iReserved;
    }

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Overdrive5_Temperature_Get(int iAdapterIndex, int iThermalControllerIndex, ref ADLTemperature lpTemperature);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Overdrive5_CurrentActivity_Get(int iAdapterIndex, ref ADLPMActivity lpActivity);

    static IntPtr Malloc(int size) { return Marshal.AllocHGlobal(size); }

    // --- Win32 / OpenGL ---
    [StructLayout(LayoutKind.Sequential)]
    struct PIXELFORMATDESCRIPTOR {
        public ushort nSize, nVersion;
        public uint dwFlags;
        public byte iPixelType, cColorBits, cRedBits, cRedShift, cGreenBits, cGreenShift, cBlueBits, cBlueShift;
        public byte cAlphaBits, cAlphaShift, cAccumBits, cAccumRedBits, cAccumGreenBits, cAccumBlueBits, cAccumAlphaBits;
        public byte cDepthBits, cStencilBits, cAuxBuffers, iLayerType, bReserved;
        public uint dwLayerMask, dwVisibleMask, dwDamageMask;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct MSG { public IntPtr hwnd; public uint message; public IntPtr wParam, lParam; public uint time; public int ptX, ptY; }

    delegate IntPtr WndProcDelegate(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    struct WNDCLASS {
        public uint style;
        public WndProcDelegate lpfnWndProc;
        public int cbClsExtra, cbWndExtra;
        public IntPtr hInstance, hIcon, hCursor, hbrBackground;
        public string lpszMenuName, lpszClassName;
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto)] static extern ushort RegisterClass(ref WNDCLASS lpWndClass);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] static extern IntPtr CreateWindowEx(uint dwExStyle, string lpClassName, string lpWindowName, uint dwStyle, int x, int y, int nWidth, int nHeight, IntPtr hWndParent, IntPtr hMenu, IntPtr hInstance, IntPtr lpParam);
    [DllImport("user32.dll")] static extern bool DestroyWindow(IntPtr hWnd);
    [DllImport("user32.dll")] static extern IntPtr DefWindowProc(IntPtr hWnd, uint uMsg, IntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll")] static extern bool PeekMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax, uint wRemoveMsg);
    [DllImport("user32.dll")] static extern bool TranslateMessage(ref MSG lpMsg);
    [DllImport("user32.dll")] static extern IntPtr DispatchMessage(ref MSG lpMsg);
    [DllImport("user32.dll")] static extern IntPtr GetDC(IntPtr hWnd);
    [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("kernel32.dll")] static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("gdi32.dll")] static extern int ChoosePixelFormat(IntPtr hdc, ref PIXELFORMATDESCRIPTOR ppfd);
    [DllImport("gdi32.dll")] static extern bool SetPixelFormat(IntPtr hdc, int format, ref PIXELFORMATDESCRIPTOR ppfd);
    [DllImport("gdi32.dll")] static extern bool SwapBuffers(IntPtr hdc);

    [DllImport("opengl32.dll")] static extern IntPtr wglCreateContext(IntPtr hdc);
    [DllImport("opengl32.dll")] static extern bool wglMakeCurrent(IntPtr hdc, IntPtr hglrc);
    [DllImport("opengl32.dll")] static extern bool wglDeleteContext(IntPtr hglrc);
    [DllImport("opengl32.dll")] static extern IntPtr wglGetProcAddress(string lpszProc);
    [DllImport("opengl32.dll")] static extern void glViewport(int x, int y, int width, int height);
    [DllImport("opengl32.dll")] static extern void glClearColor(float r, float g, float b, float a);
    [DllImport("opengl32.dll")] static extern void glClear(uint mask);
    [DllImport("opengl32.dll")] static extern void glEnable(uint cap);
    [DllImport("opengl32.dll")] static extern void glBlendFunc(uint sfactor, uint dfactor);
    [DllImport("opengl32.dll")] static extern void glMatrixMode(uint mode);
    [DllImport("opengl32.dll")] static extern void glLoadIdentity();
    [DllImport("opengl32.dll")] static extern void glRotatef(float angle, float x, float y, float z);
    [DllImport("opengl32.dll")] static extern uint glGenLists(int range);
    [DllImport("opengl32.dll")] static extern void glNewList(uint list, uint mode);
    [DllImport("opengl32.dll")] static extern void glEndList();
    [DllImport("opengl32.dll")] static extern void glCallList(uint list);
    [DllImport("opengl32.dll")] static extern void glBegin(uint mode);
    [DllImport("opengl32.dll")] static extern void glEnd();
    [DllImport("opengl32.dll")] static extern void glColor4f(float r, float g, float b, float a);
    [DllImport("opengl32.dll")] static extern void glVertex3f(float x, float y, float z);
    [DllImport("opengl32.dll")] static extern void glFinish();

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate bool wglSwapIntervalEXT_t(int interval);

    static IntPtr WndProc(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam) {
        return DefWindowProc(hWnd, msg, wParam, lParam);
    }

    static void Main(string[] args) {
        int durationSec = 60;
        if (args.Length > 0) int.TryParse(args[0], out durationSec);

        ADL_MAIN_MALLOC_CALLBACK cb = new ADL_MAIN_MALLOC_CALLBACK(Malloc);
        bool adlOk = (ADL_Main_Control_Create(cb, 1) == 0);

        // Idle reading
        double idleTemp = 0; int idleCore = 0, idleMem = 0, idleLoad = 0, idleBus = 0;
        if (adlOk) {
            ADLTemperature t = new ADLTemperature { iSize = Marshal.SizeOf(typeof(ADLTemperature)) };
            ADLPMActivity a = new ADLPMActivity { iSize = Marshal.SizeOf(typeof(ADLPMActivity)) };
            if (ADL_Overdrive5_Temperature_Get(0, 0, ref t) == 0) idleTemp = t.iTemperature / 1000.0;
            if (ADL_Overdrive5_CurrentActivity_Get(0, ref a) == 0) {
                idleCore = a.iEngineClock / 100;
                idleMem = a.iMemoryClock / 100;
                idleLoad = a.iActivityPercent;
                idleBus = a.iCurrentBusSpeed;
            }
        }

        WNDCLASS wc = new WNDCLASS {
            style = 0x0020, // CS_OWNDC
            lpfnWndProc = WndProc,
            hInstance = GetModuleHandle(null),
            lpszClassName = "Rx550BenchCls"
        };
        RegisterClass(ref wc);
        IntPtr hwnd = CreateWindowEx(0, "Rx550BenchCls", "RX550 60s Benchmark", 0x10CF0000, 50, 50, 1280, 720, IntPtr.Zero, IntPtr.Zero, wc.hInstance, IntPtr.Zero);
        IntPtr hdc = GetDC(hwnd);

        PIXELFORMATDESCRIPTOR pfd = new PIXELFORMATDESCRIPTOR {
            nSize = (ushort)Marshal.SizeOf(typeof(PIXELFORMATDESCRIPTOR)),
            nVersion = 1,
            dwFlags = 0x0004 | 0x0020 | 0x0001, // DRAW_TO_WINDOW | SUPPORT_OPENGL | DOUBLEBUFFER
            iPixelType = 0,
            cColorBits = 32,
            cDepthBits = 24
        };
        int pf = ChoosePixelFormat(hdc, ref pfd);
        SetPixelFormat(hdc, pf, ref pfd);
        IntPtr hglrc = wglCreateContext(hdc);
        wglMakeCurrent(hdc, hglrc);

        IntPtr swapPtr = wglGetProcAddress("wglSwapIntervalEXT");
        if (swapPtr != IntPtr.Zero) {
            var swapInterval = (wglSwapIntervalEXT_t)Marshal.GetDelegateForFunctionPointer(swapPtr, typeof(wglSwapIntervalEXT_t));
            swapInterval(0);
        }

        glViewport(0, 0, 1280, 720);
        glEnable(0x0BE2); // GL_BLEND
        glBlendFunc(0x0302, 0x0303); // SRC_ALPHA, ONE_MINUS_SRC_ALPHA

        // Build a heavy GPU-bound display list (dense overlapping shaded quads -> high pixel fillrate/ROP/shader load)
        uint listId = glGenLists(1);
        glNewList(listId, 0x1300); // GL_COMPILE
        glBegin(0x0007); // GL_QUADS
        for (int layer = 0; layer < 40; layer++) {
            float z = -0.9f + layer * 0.045f;
            float r = (layer % 3 == 0) ? 0.8f : 0.2f;
            float g = (layer % 3 == 1) ? 0.8f : 0.3f;
            float b = (layer % 3 == 2) ? 0.8f : 0.4f;
            for (int i = 0; i < 16; i++) {
                float x0 = -0.95f + (i % 4) * 0.45f;
                float y0 = -0.95f + (i / 4) * 0.45f;
                glColor4f(r, g, b, 0.06f);
                glVertex3f(x0, y0, z);
                glVertex3f(x0 + 0.55f, y0, z);
                glVertex3f(x0 + 0.55f, y0 + 0.55f, z);
                glVertex3f(x0, y0 + 0.55f, z);
            }
        }
        glEnd();
        glEndList();

        // Warmup 2 seconds
        Stopwatch sw = Stopwatch.StartNew();
        MSG msg;
        while (sw.ElapsedMilliseconds < 2000) {
            while (PeekMessage(out msg, IntPtr.Zero, 0, 0, 1)) { TranslateMessage(ref msg); DispatchMessage(ref msg); }
            glClearColor(0.05f, 0.05f, 0.08f, 1.0f);
            glClear(0x4000 | 0x0100);
            glMatrixMode(0x1700);
            glLoadIdentity();
            glRotatef((float)(sw.Elapsed.TotalSeconds * 45.0), 0.3f, 0.7f, 0.2f);
            glCallList(listId);
            glFinish();
            SwapBuffers(hdc);
        }

        // Benchmark loop
        List<double> frameTimesMs = new List<double>(16384);
        double maxTemp = idleTemp;
        int maxCore = 0, maxMem = 0, maxLoad = 0, maxBus = 0;
        List<int> coreSamples = new List<int>();
        List<int> memSamples = new List<int>();

        sw.Restart();
        long lastTicks = sw.ElapsedTicks;
        long lastAdlMs = 0;
        double ticksToMs = 1000.0 / Stopwatch.Frequency;

        while (sw.Elapsed.TotalSeconds < durationSec) {
            while (PeekMessage(out msg, IntPtr.Zero, 0, 0, 1)) { TranslateMessage(ref msg); DispatchMessage(ref msg); }
            glClearColor(0.05f, 0.05f, 0.08f, 1.0f);
            glClear(0x4000 | 0x0100);
            glMatrixMode(0x1700);
            glLoadIdentity();
            glRotatef((float)(sw.Elapsed.TotalSeconds * 60.0), 0.4f, 0.8f, 0.3f);
            glCallList(listId);
            glFinish();
            SwapBuffers(hdc);

            long nowTicks = sw.ElapsedTicks;
            frameTimesMs.Add((nowTicks - lastTicks) * ticksToMs);
            lastTicks = nowTicks;

            long ms = sw.ElapsedMilliseconds;
            if (adlOk && ms - lastAdlMs >= 500) {
                lastAdlMs = ms;
                ADLTemperature t = new ADLTemperature { iSize = Marshal.SizeOf(typeof(ADLTemperature)) };
                ADLPMActivity a = new ADLPMActivity { iSize = Marshal.SizeOf(typeof(ADLPMActivity)) };
                if (ADL_Overdrive5_Temperature_Get(0, 0, ref t) == 0) {
                    double tc = t.iTemperature / 1000.0;
                    if (tc > maxTemp) maxTemp = tc;
                }
                if (ADL_Overdrive5_CurrentActivity_Get(0, ref a) == 0) {
                    int c = a.iEngineClock / 100;
                    int m = a.iMemoryClock / 100;
                    if (c > maxCore) maxCore = c;
                    if (m > maxMem) maxMem = m;
                    if (a.iActivityPercent > maxLoad) maxLoad = a.iActivityPercent;
                    if (a.iCurrentBusSpeed > maxBus) maxBus = a.iCurrentBusSpeed;
                    coreSamples.Add(c);
                    memSamples.Add(m);
                }
            }
        }
        double totalSec = sw.Elapsed.TotalSeconds;

        wglMakeCurrent(IntPtr.Zero, IntPtr.Zero);
        wglDeleteContext(hglrc);
        ReleaseDC(hwnd, hdc);
        DestroyWindow(hwnd);
        if (adlOk) ADL_Main_Control_Destroy();

        int totalFrames = frameTimesMs.Count;
        double avgFps = totalFrames / totalSec;
        frameTimesMs.Sort();
        double avgFt = 0;
        foreach (var ft in frameTimesMs) avgFt += ft;
        avgFt /= totalFrames;

        int onePctCount = Math.Max(1, totalFrames / 100);
        double slowSum = 0;
        for (int i = totalFrames - onePctCount; i < totalFrames; i++) slowSum += frameTimesMs[i];
        double onePctLowFt = slowSum / onePctCount;
        double onePctLowFps = 1000.0 / onePctLowFt;
        double p99Ft = frameTimesMs[(int)(totalFrames * 0.99)];

        double avgCore = 0, avgMem = 0;
        if (coreSamples.Count > 0) {
            foreach (var c in coreSamples) avgCore += c;
            avgCore /= coreSamples.Count;
            foreach (var m in memSamples) avgMem += m;
            avgMem /= memSamples.Count;
        }

        Console.WriteLine(string.Format("Idle: Temp={0:F1}C Core={1}MHz Mem={2}MHz Load={3}% BusSpeed={4}MT/s", idleTemp, idleCore, idleMem, idleLoad, idleBus));
        Console.WriteLine(string.Format("Load: Duration={0:F2}s Frames={1} AvgFPS={2:F2} 1%LowFPS={3:F2} AvgFT={4:F2}ms P99FT={5:F2}ms", totalSec, totalFrames, avgFps, onePctLowFps, avgFt, p99Ft));
        Console.WriteLine(string.Format("GPU_Load: MaxTemp={0:F1}C AvgCore={1:F0}MHz MaxCore={2}MHz AvgMem={3:F0}MHz MaxMem={4}MHz MaxLoad={5}% MaxBusSpeed={6}MT/s", maxTemp, avgCore, maxCore, avgMem, maxMem, maxLoad, maxBus));
    }
}
