JX=./vendor/bin/jx

install:
	$(JX) install --no-optional
	rm -rf node_modules/simple-websocket

synx:
	synx -e /Pods -e /vendor ./Peerflix.xcodeproj
