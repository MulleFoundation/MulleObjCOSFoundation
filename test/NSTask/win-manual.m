//
//  win-manual.m
//  Test Windows pipe/process creation directly
//

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#include <windows.h>
#include <stdio.h>

int main(int argc, const char * argv[])
{
   HANDLE hStdoutRead, hStdoutWrite;
   SECURITY_ATTRIBUTES sa;
   STARTUPINFOW si;
   PROCESS_INFORMATION pi;
   DWORD bytesRead;
   char buffer[4096];
   BOOL success;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // Setup security attributes for inheritable handles
      sa.nLength = sizeof(SECURITY_ATTRIBUTES);
      sa.bInheritHandle = TRUE;
      sa.lpSecurityDescriptor = NULL;

      // Create pipe for stdout
      if (!CreatePipe(&hStdoutRead, &hStdoutWrite, &sa, 0))
      {
         mulle_fprintf(stderr, "CreatePipe failed: %lu\n", GetLastError());
         return 1;
      }

      // Make read end non-inheritable
      if (!SetHandleInformation(hStdoutRead, HANDLE_FLAG_INHERIT, 0))
      {
         mulle_fprintf(stderr, "SetHandleInformation failed: %lu\n", GetLastError());
         return 1;
      }

      // Setup startup info
      ZeroMemory(&si, sizeof(si));
      si.cb = sizeof(si);
      si.dwFlags = STARTF_USESTDHANDLES;
      si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
      si.hStdOutput = hStdoutWrite;
      si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

      ZeroMemory(&pi, sizeof(pi));

      // Create process
      success = CreateProcessW(
         NULL,
         L"cmd.exe /c echo PASS",
         NULL,
         NULL,
         TRUE,
         0,
         NULL,
         NULL,
         &si,
         &pi
      );

      if (!success)
      {
         mulle_fprintf(stderr, "CreateProcess failed: %lu\n", GetLastError());
         CloseHandle(hStdoutRead);
         CloseHandle(hStdoutWrite);
         return 1;
      }

      // Close write end in parent
      CloseHandle(hStdoutWrite);

      // Wait for process
      WaitForSingleObject(pi.hProcess, INFINITE);

      // Read output
      while (ReadFile(hStdoutRead, buffer, sizeof(buffer) - 1, &bytesRead, NULL) && bytesRead > 0)
      {
         buffer[bytesRead] = 0;
         mulle_printf("%s", buffer);
      }

      CloseHandle(hStdoutRead);
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
   }

   return 0;
}
