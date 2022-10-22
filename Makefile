build:
	mkdir -p build
	mkdir -p build/test
test/build: build Bloom_Filter/test/*.pony
	corral fetch
	corral run -- ponyc Bloom_Filter/test -o build/test --debug
test: test/build
	./build/test/test --sequential
clean:
	rm -rf build

.PHONY: clean test
