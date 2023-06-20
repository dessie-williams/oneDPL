$ErrorActionPreference = 'Continue'


$cmd_args = @"
call %CONDA%/condabin/conda.bat activate base
if (${env:matrix.backend} -eq 'dpcpp' {
  set ninja_targets="build-onedpl-sycl_iterator-tests"
  set ctest_flags=-R sycl_iterator_.*\.pass
  echo ::warning::dpcpp backend is set. Compile and run only sycl_iterator tests
} else {
  set ninja_targets=build-onedpl-tests
}
if (${env:matrix.cxx_compiler} -eq 'icpx' {
  set TMP_INTEL_LLVM_COMPILER=TRUE
}
if (${env:matrix.cxx_compiler} -eq 'icx' {
  set TMP_INTEL_LLVM_COMPILER=TRUE
}
if (${env:matrix.cxx_compiler} -eq 'icx-cl' {
  set TMP_INTEL_LLVM_COMPILER=TRUE
}
if (${env:matrix.cxx_compiler} -eq 'dpcpp' {
  set TMP_INTEL_LLVM_COMPILER=TRUE
}
if (${env:matrix.cxx_compiler} -eq 'dpcpp-cl' {
  set TMP_INTEL_LLVM_COMPILER=TRUE
}
if "%TMP_INTEL_LLVM_COMPILER%" == "TRUE" (
  powershell $output = (${env:matrix.cxx_compiler} --version; Write-Host ::warning::Compiler: $output
  powershell -Command "(Get-Content '%CONDA_PREFIX%\Library\lib\cl.cfg') -replace 'CL_CONFIG_TBB_DLL_PATH = .*', 'CL_CONFIG_TBB_DLL_PATH = %CONDA_PREFIX%\Library\bin' | Out-File -encoding ASCII -FilePath '%CONDA_PREFIX%\Library\lib\cl.cfg'"
)
mkdir build && cd build
call "C:\Program Files (x86)\Microsoft Visual Studio\\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64          
set INCLUDE=%CONDA_PREFIX%\Library\include;%INCLUDE%
set LIB=%CONDA_PREFIX%\Library\lib;%LIB%
set PATH=%CONDA_PREFIX%\Library\lib;%PATH%
set CPATH=%CONDA_PREFIX%\include
set TBB_DLL_PATH=%CONDA_PREFIX%\Library\bin
reg add HKLM\SOFTWARE\khronos\OpenCL\Vendors /v intelocl64.dll /t REG_DWORD /d 00000000
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=(${env:matrix.build_type} -DCMAKE_CXX_STANDARD=(${env:matrix.std} -DCMAKE_CXX_COMPILER=(${env:matrix.cxx_compiler} -DONEDPL_BACKEND=(${env:matrix.backend} -DONEDPL_DEVICE_TYPE=(${env:matrix.device_type} ..
ninja -j 2 -v %ninja_targets%
ctest --timeout %TEST_TIMEOUT% -C (${env:matrix.build_type} --output-on-failure %ctest_flags%        
"@

$cmd_args = [string]::join(" ", ($cmd_args.Split("`n")))
cmd /v /c $cmd_args

exit ${LastExitCode}
