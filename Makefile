pg:
	fvm flutter pub get

lint:
	fvm flutter analyze

# CI ENV
env:
	sh scripts/env.sh

build_android:
	sh scripts/build_android.sh

build_ios:
	make env
	sh scripts/build_ios.sh

build_both:
	make build_android
	make build_ios