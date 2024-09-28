#include <iostream>
#include <string_view>

struct Thing {
public:
    Thing(int i) : i(i) {}

    template<typename T>
    void output(T t) const {
        std::cout << prefix() << t << '\n';
    }
private:
    std::string_view prefix() const;
    int i;
};

