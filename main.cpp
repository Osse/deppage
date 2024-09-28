#include <iostream>
#include "mylib.h"

int main(int argc, char *argv[])
{
    Thing t(5);
    t.output(std::string_view("lol"));
    return 0;
}
