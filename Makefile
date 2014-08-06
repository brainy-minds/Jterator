

clean:
	if [ -d build ]; then rm -rf build; fi
	if [ -d dist ]; then rm -rf dist; fi
	if [ -d Jterator.egg-info ]; then rm -rf Jterator.egg-info; fi
