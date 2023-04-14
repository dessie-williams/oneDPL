@echo off

"C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
set INCLUDE=%CONDA_PREFIX%\Library\include;%INCLUDE%
set LIB=%CONDA_PREFIX%\Library\lib;%LIB%
set PATH=%CONDA_PREFIX%\Library\lib;%PATH%
set CPATH=%CONDA_PREFIX%\include
set TBB_DLL_PATH=%CONDA_PREFIX%\Library\bin
reg add HKLM\SOFTWARE\khronos\OpenCL\Vendors /v intelocl64.dll /t REG_DWORD /d 00000000
mkdir build && cd build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=%matrix.build_type% -DCMAKE_CXX_STANDARD=%matrix.std% -DCMAKE_CXX_COMPILER=%matrix.cxx_compiler% -DONEDPL_BACKEND=%matrix.backend% -DONEDPL_DEVICE_TYPE=%matrix.device_type% ..
ninja -j 2 -v %ninja_targets%
ctest --timeout %TEST_TIMEOUT% -C %matrix.build_type% --output-on-failure %ctest_flags%

exit /b 0
