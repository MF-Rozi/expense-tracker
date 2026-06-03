.PHONY: get
get:
	@fvm flutter pub get

.PHONY: build
build:
	@fvm flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch:
	@fvm flutter pub run build_runner watch --delete-conflicting-outputs

.PHONY: apk-dev
apk-dev:
	@fvm flutter build apk --debug --flavor development --target lib/main_development.dart

.PHONY: apk-stg
apk-stg:
	@fvm flutter build apk --profile --flavor staging --target lib/main_staging.dart

.PHONY: apk-prod
apk-prod:
	@fvm flutter build apk --release --flavor production --target lib/main_production.dart

.PHONY: ipa-dev
ipa-dev:
	@fvm flutter build ipa --debug --flavor development --target lib/main_development.dart

.PHONY: ipa-stg
ipa-stg:
	@fvm flutter build ipa --profile --flavor staging --target lib/main_staging.dart

.PHONY: ipa-prod
ipa-prod:
	@fvm flutter build ipa --release --flavor production --target lib/main_production.dart

.PHONY: test
test:
	@fvm flutter test --coverage --test-randomize-ordering-seed random

.PHONY: fix
fix:
	@fvm dart fix --apply

.PHONY: check-fix
check-fix:
	@fvm dart fix --dry-run

.PHONY: firebase-dev
firebase-dev:
	@flutterfire config -y --account ${FIREBASE_EMAIL} --project=${FIREBASE_PROJECT_ID_DEV} --out=lib/firebase_options_dev.dart  --ios-bundle-id=${PROJECT_PACKAGE}.dev --android-package-name=${PROJECT_PACKAGE}.dev

.PHONY: firebase-stg
firebase-stg:
	@flutterfire config -y --account ${FIREBASE_EMAIL} --project=${FIREBASE_PROJECT_ID_STG} --out=lib/firebase_options_stg.dart  --ios-bundle-id=${PROJECT_PACKAGE}.stg --android-package-name=${PROJECT_PACKAGE}.stg

.PHONY: firebase-prod
firebase-prod:
	@flutterfire config -y --account ${FIREBASE_EMAIL} --project=${FIREBASE_PROJECT_ID_PROD} --out=lib/firebase_options.dart  --ios-bundle-id=${PROJECT_PACKAGE} --android-package-name=${PROJECT_PACKAGE}

.PHONY: analyze
analyze:
	@fvm dart analyze lib test

.PHONY: format
format:
	@fvm dart format --set-exit-if-changed lib test

.PHONY: prepare
prepare: fix format analyze
