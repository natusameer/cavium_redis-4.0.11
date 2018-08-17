# Top level makefile, the real shit is at src/Makefile
bench:
	cd src && $(MAKE) -j all
	echo -e "\n\n=============Starting Benchmarking Test=============\n\n"
	bash bench.sh
.PHONY: bench

distclean:
	cd src && $(MAKE) distclean
.PHONY: distclean


clean:
	cd src && $(MAKE) clean
.PHONY: clean

build:
	cd src && $(MAKE) -j all
.PHONY: build
