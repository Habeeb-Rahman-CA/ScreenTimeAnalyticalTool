#include <windows.h>
#include <iostream>
int main() {
    LASTINPUTINFO lii;
    lii.cbSize = sizeof(LASTINPUTINFO);
    if (GetLastInputInfo(&lii)) {
        std::cout << GetTickCount() - lii.dwTime << std::endl;
    }
    return 0;
}
