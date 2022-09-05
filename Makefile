FLUTTER := $(shell which flutter)
FLUTTER_BIN_DIR := $(shell dirname $(FLUTTER))
DART := $(FLUTTER_BIN_DIR)/cache/dart-sdk/bin/dart

default: clean format-fix lint test start

start:
	$(FLUTTER) run

start-release:
	$(FLUTTER) run --release

format:
	$(FLUTTER) format . --line-length 120 --set-exit-if-changed

format-fix:
	$(FLUTTER) format . --line-length 120

lint:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test
.PHONY: test

docs:
	cd docs; npm install && npm run docs:dev
.PHONY: docs

packages-outdated:
	$(FLUTTER) pub outdated

packages-upgrade:
	$(FLUTTER) pub upgrade

clean:
	$(FLUTTER) clean
	$(FLUTTER) pub get

clean-hard:
	rm -rf pubspec.lock
	rm -rf ios/Podfile.lock
	rm -rf ios/.symlinks
	rm -rf ios/Pods
	rm -rf ios/Runner.xcworkspace
	# $(FLUTTER) pub cache repair
	make clean
	$(FLUTTER) pub upgrade

splashscreen-generate:
	$(FLUTTER) pub run flutter_native_splash:create

appicon-generate:
	$(FLUTTER) pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml

build-ios:
	@echo "Build iOS"
	make clean
	rm -rf ios/build-output
	flutter build ipa
	cp build/ios/ipa/bibkat.ipa build-output/bibkat.ipa

build-android-apk:
	@echo "Build APK's"
	make clean
	$(FLUTTER) build apk --target-platform android-arm,android-arm64
	cp build/app/outputs/apk/release/app-release.apk build-output/
	mv build-output/app-release.apk build-output/app.apk

build-android-aab:
	@echo "Build Store App Bundle"
	make clean
	$(FLUTTER) build appbundle
	cp build/app/outputs/bundle/release/app-release.aab build-output/
	mv build-output/app-release.aab build-output/app.aab

release-ios:
	@echo "Release iOS"
	cd ios; bundle exec fastlane deploy

release-android:
	@echo "Release Android"
	cd android; bundle exec fastlane deploy