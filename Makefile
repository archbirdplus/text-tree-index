
main: utils.swift init.swift query.swift main.swift
	time swiftc utils.swift init.swift query.swift main.swift -O -D RELEASE -o main

debug-main: utils.swift init.swift query.swift main.swift
	echo "compiling for testing..." && time swiftc utils.swift init.swift query.swift main.swift -o debug-main

test-init: debug-main
	rm -f README.md.index && echo "initializing index..." && time ./debug-main init README.md ""

test-query: debug-main
	./debug-main query README.md.index "abc" "Alg" "wou"


