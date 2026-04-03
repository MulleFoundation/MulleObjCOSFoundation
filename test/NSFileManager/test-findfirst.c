#include <windows.h>
#include <stdio.h>

int main(void)
{
    WIN32_FIND_DATAW findData;
    HANDLE hFind;
    wchar_t pattern[] = L"demo\\*";

    mulle_printf("Testing FindFirstFileW with pattern: demo\\*\n");
    
    hFind = FindFirstFileW(pattern, &findData);

    if (hFind == INVALID_HANDLE_VALUE)
    {
        DWORD err = GetLastError();
        mulle_printf("FindFirstFileW failed (error %lu)\n", err);
        return 1;
    }

    mulle_printf("FindFirstFileW succeeded!\n");
    mulle_printf("First entry: %ls\n", findData.cFileName);

    do
    {
        if (wcscmp(findData.cFileName, L".") == 0 ||
            wcscmp(findData.cFileName, L"..") == 0)
        {
            continue;
        }

        mulle_printf("Found: %ls\n", findData.cFileName);

    } while (FindNextFileW(hFind, &findData) != 0);

    FindClose(hFind);
    mulle_printf("Done!\n");
    return 0;
}
