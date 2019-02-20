DESTDIR=/usr/local/bin

all:
	@echo do: "make install" to install to $(DESTDIR), and read README.txt

install:
	install -o root -g root -m 0755 extract_tracking_number ips ips_cleanup $(DESTDIR)

update:
	git pull --all

publish:
	git push --all
