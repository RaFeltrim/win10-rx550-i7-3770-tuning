using System;
using System.Runtime.InteropServices;

class AdlReader {
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate IntPtr ADL_MAIN_MALLOC_CALLBACK(int size);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Main_Control_Create(ADL_MAIN_MALLOC_CALLBACK callback, int enumConnectedAdapters);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Main_Control_Destroy();

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Adapter_NumberOfAdapters_Get(ref int numAdapters);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    struct AdapterInfo {
        public int iSize;
        public int iAdapterIndex;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strUDID;
        public int iBusNumber;
        public int iDeviceNumber;
        public int iFunctionNumber;
        public int iVendorID;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strAdapterName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strDisplayName;
        public int iPresent;
        public int iExist;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strDriverPath;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strDriverPathExt;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string strPNPString;
        public int iOSDisplayIndex;
    }

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Adapter_AdapterInfo_Get(IntPtr lpInfo, int iInputSize);

    [StructLayout(LayoutKind.Sequential)]
    struct ADLTemperature {
        public int iSize;
        public int iTemperature;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct ADLPMActivity {
        public int iSize;
        public int iEngineClock;
        public int iMemoryClock;
        public int iVddc;
        public int iActivityPercent;
        public int iCurrentPerformanceLevel;
        public int iCurrentBusSpeed;
        public int iCurrentBusLanes;
        public int iMaximumBusLanes;
        public int iReserved;
    }

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Overdrive5_Temperature_Get(int iAdapterIndex, int iThermalControllerIndex, ref ADLTemperature lpTemperature);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL_Overdrive5_CurrentActivity_Get(int iAdapterIndex, ref ADLPMActivity lpActivity);

    [DllImport("atiadlxx.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int ADL2_OverdriveN_Temperature_Get(IntPtr context, int iAdapterIndex, int iTempType, ref int iTemperature);

    static IntPtr Malloc(int size) { return Marshal.AllocHGlobal(size); }

    static void Main() {
        ADL_MAIN_MALLOC_CALLBACK cb = new ADL_MAIN_MALLOC_CALLBACK(Malloc);
        int res = ADL_Main_Control_Create(cb, 1);
        Console.WriteLine("ADL_Main_Control_Create: " + res);
        if (res != 0) return;

        int num = 0;
        ADL_Adapter_NumberOfAdapters_Get(ref num);
        Console.WriteLine("Adapters: " + num);
        if (num > 0) {
            int size = Marshal.SizeOf(typeof(AdapterInfo)) * num;
            IntPtr ptr = Marshal.AllocHGlobal(size);
            ADL_Adapter_AdapterInfo_Get(ptr, size);
            for (int i = 0; i < num; i++) {
                AdapterInfo info = (AdapterInfo)Marshal.PtrToStructure(IntPtr.Add(ptr, i * Marshal.SizeOf(typeof(AdapterInfo))), typeof(AdapterInfo));
                if (info.iVendorID == 1002 || info.iVendorID == 0x1002) {
                    ADLTemperature temp = new ADLTemperature { iSize = Marshal.SizeOf(typeof(ADLTemperature)) };
                    int tres = ADL_Overdrive5_Temperature_Get(info.iAdapterIndex, 0, ref temp);
                    ADLPMActivity act = new ADLPMActivity { iSize = Marshal.SizeOf(typeof(ADLPMActivity)) };
                    int ares = ADL_Overdrive5_CurrentActivity_Get(info.iAdapterIndex, ref act);
                    Console.WriteLine(string.Format("Idx={0} Name={1} TempRes={2} TempC={3:F1} ActRes={4} CoreMHz={5} MemMHz={6} Load={7}% BusSpeed={8} Lanes={9}/{10}",
                        info.iAdapterIndex, info.strAdapterName, tres, temp.iTemperature / 1000.0, ares,
                        act.iEngineClock / 100, act.iMemoryClock / 100, act.iActivityPercent,
                        act.iCurrentBusSpeed, act.iCurrentBusLanes, act.iMaximumBusLanes));
                    break;
                }
            }
            Marshal.FreeHGlobal(ptr);
        }
        ADL_Main_Control_Destroy();
    }
}
