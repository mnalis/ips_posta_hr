Auto e-mail tracking posiljaka preko https://tnt.posta.hr, kratke upute za instalaciju i koristenje

by Matija Nalis <mnalis-perl@voyager.hr> released under GPLv3+ license. Patches welcome.


1) download svih datoteka i potrebnih paketa

	git clone https://github.com/mnalis/ips_posta_hr.git
	cd ips_posta_hr
	sudo make install
        sudo apt-get install perl libhtml-tableextract-perl
	mkdir ~/.ips_posta_hr

2) dodaj automatske obavijesti e-mailom i automatsko praznjenje kada posiljke stignu 
	(NOTE: grepaj "FIXME" po scriptama prvo ako nisi iz Zagreba)
	"crontab -e" kao user, pa dodaj redove:
		0 * * * * /usr/local/bin/ips DOIT
		40 20 * * * /usr/local/bin/ips_cleanup 7
	
        ("ips_cleanup 7" ce obrisati posiljke koje su oznacene kao isporucene duze od 7 dana)

3) (opcionalno) set up procmail za automatski tracking
	wget http://linux.voyager.hr/ips/procmailrc

	i onda update svoj ~/.procmailrc sa tim i slicnim 
 	(dodati koje mailove da automatski pocinje pratiti)

4) (opcionalno) rucno dodavanje posiljaka za pracenje ili dodatnih informacija
	ips RT123456789HK			# dodaje posiljku u tracking
	ips RT123456789HK 'CREE LED 1xAA'	# dodaje posiljku u tracking sa opisom, 
						# ili updatea opis ako se posiljka vec prati
	ips RT123456789HK '' 'sender@domena.com' # dodaje posilju u tracking sa senderom, 
						# ili updatea sendera ako se posiljka vec prati
						# (extract_tracking_number radi ovo automatski)

	ips RT123456789HK 'CREE LED 1xAA' 'sender@domena.com'	# dodaje/updatea posiljku i opis i sendera


Sistem ce na e-mail usera (ako je cron tako podesen) automatski poslati mail kada se promijeni status neke posiljke,
kao i zadnji status svih trenutnih posiljaka. Zadnji se moze provjeriti i pokretanjem "ips" bez parametara; a full 
stanja svih posiljaka koje jos nisu dosle sa "less ~/.ips_posta_hr/*.txt"
