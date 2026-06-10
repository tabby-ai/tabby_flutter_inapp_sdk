pg:
	fvm flutter pub get

lint:
	fvm flutter analyze

# CI ENV
env:
	sh scripts/env.sh

pre_build:
	fvm use
	fvm flutter clean
	cd example
	fvm flutter clean
	cd ..
	make pg

build_android:
	make pre_build
	make env
	sh scripts/build_android.sh

build_ios:
	make pre_build
	make env
	sh scripts/build_ios.sh

build_both:
	make pre_build
	make env
	sh scripts/build_android.sh
	sh scripts/build_ios.sh

publish:
	fvm dart pub publish

pods:
	fvm flutter precache --ios
	pod install --repo-update --project-directory=example/ios

tests:
	fvm flutter test