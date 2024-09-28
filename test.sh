#!/bin/bash

die() {
    printf '%s\n' "$@"
    exit 1
}

for dep in cmake g++ clang++-18 ninja sccache make; do
    command -v "$dep" >/dev/null || die "Missing dependency $dep"
done

prepare_build() {
    if [[ -n "$sccache" ]]; then
        # Need to stop sccache in order to change cache directory
        sccache --stop-server &>/dev/null
        export SCCACHE_DIR="$PWD/sccache/$buildir"
    fi
    buildir="build-${sccache:-none}-$compiler-$shared-${generator:-Make}-$version"
}

configure_and_build() {
    prepare_build

    git checkout HEAD -- mylib/include/mylib.h

    cmake -B "$buildir" -S . -DCMAKE_BUILD_TYPE=Debug \
        ${generator:+-G $generator} \
        -DOSSE_VERSION=$version \
        -DCMAKE_CXX_COMPILER=$compiler \
        ${sccache:+-DCMAKE_CXX_COMPILER_LAUNCHER=$sccache} \
        -DBUILD_SHARED_LIBS=$shared &>/dev/null || die "Configure $buildir failed"

    if [[ $generator = Ninja ]]; then
        ninja -C "$buildir" -t compdb > "$buildir/compile_commands.json"
        #jq '.[] | select(.output |test("\\.o\\."))' "$buildir/compile_commands.json"
    fi

    cmake --build "$buildir" &>/dev/null
}

modify() {
    mod=$(stat --format=%Y "$buildir"/proj)
    sleep 1
    # touch mylib/include/mylib.h
    echo '' >> mylib/include/mylib.h
    # sed -i 's/<< t /<< t << t /' mylib/include/mylib.h
    sleep 1
}

check_rebuild() {
    prepare_build

    mod=$(stat --format=%Y "$buildir"/proj)


    cmake --build "$buildir" # -- -d explain

    modafter=$(stat --format=%Y "$buildir"/proj)

    if (( modafter > mod )); then
        echo $buildir: YES
    else
        echo $buildir: NO
    fi
}

do_loop() {
    caches=(
        # '' # Intentionally empty (using ${var:-} and ${var:+})
        sccache
    )
    compilers=(
        # g++
        clang++-18
    )
    shared_settings=(
        # ON
        OFF
    )
    generators=(
        # '' # Default Unix Makefiles
        Ninja
    )
    versions=(
        3.26
        3.28
        3.10
    )

    for sccache in "${caches[@]}"; do
        for compiler in "${compilers[@]}"; do
            for shared in "${shared_settings[@]}"; do
                for generator in "${generators[@]}"; do
                    for version in "${versions[@]}"; do
                        "$1"
                    done
                done
            done
        done
    done

    printf '%s: Done\n' "$1"
}

echo "Resetting..."
rm -rf sccache build-*
git checkout HEAD -- mylib/include/mylib.h

do_loop configure_and_build
modify
do_loop check_rebuild

echo "Clearing build dirs and doing it all again..."
rm -rf build-*
git checkout HEAD -- mylib/include/mylib.h

do_loop configure_and_build
modify
do_loop check_rebuild
