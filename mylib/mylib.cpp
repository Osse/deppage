#include "include/mylib.h"

std::string_view Thing::prefix() const
{
    return std::string_view("hello: ");
}
