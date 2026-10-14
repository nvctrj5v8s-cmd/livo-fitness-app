import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/consent/data/consent_repository.dart';
import 'package:fitness_ai_app/features/consent/domain/consent.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_cloud.dart';
import 'package:fitness_ai_app/features/onboarding/data/personalization_store.dart';
import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:flutter_test/flutter_test.dart';

class _DeviceStore implements PersonalizationStore {
  PersonalizationRecord record = const PersonalizationRecord();

  @override
  Future<PersonalizationRecord> load(String userId) async => record;

  @override
  Future<void> save(String userId, PersonalizationProfile profile) async {
    record = PersonalizationRecord(profile: profile);
  }

  @override
  Future<void> defer(String userId) async {
    record = const PersonalizationRecord(deferred: true);
  }

  @override
  Future<void> clear(String userId) async {
    record = const PersonalizationRecord();
  }
}

class _FakeCloud implements PersonalizationCloud {
  _FakeCloud([this.stored]);

  PersonalizationProfile? stored;
  var saves = 0;
  var deletes = 0;

  @override
  Future<PersonalizationProfile?> load() async => stored;

  @override
  Future<bool> save(PersonalizationProfile profile) async {
    saves++;
    stored = profile;
    return true;
  }

  @override
  Future<void> delete() async {
    deletes++;
    stored = null;
  }
}

class _BrokenCloud implements PersonalizationCloud {
  @override
  Future<PersonalizationProfile?> load() async => throw StateError('offline');

  @override
  Future<bool> save(PersonalizationProfile profile) async =>
      throw StateError('offline');

  @override
  Future<void> delete() async => throw StateError('offline');
}

AppController _controller(
  _DeviceStore device,
  PersonalizationCloud cloud, {
  Map<ConsentKind, bool>? consents,
}) {
  final controller = AppController(
    personalizationUserId: 'user-a',
    personalizationStore: device,
    personalizationCloud: cloud,
    consentRepository: MemoryConsentRepository(consents),
  );
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  const answers = PersonalizationProfile(displayName: 'Max');

  test('neues Gerät: gespeicherte Antworten kommen aus dem Konto', () async {
    final device = _DeviceStore();
    final controller = _controller(device, _FakeCloud(answers));

    final record = await controller.loadPersonalization();

    expect(record.hasDecision, isTrue);
    expect(record.profile?.displayName, 'Max');
    // Kept on the device too, so the next start needs no download.
    expect(device.record.profile?.displayName, 'Max');
  });

  test(
    'Antworten auf dem Gerät haben Vorrang und werden nicht überschrieben',
    () async {
      final device = _DeviceStore()
        ..record = const PersonalizationRecord(
          profile: PersonalizationProfile(displayName: 'Lokal'),
        );
      final cloud = _FakeCloud(answers);
      final controller = _controller(device, cloud);

      final record = await controller.loadPersonalization();

      expect(record.profile?.displayName, 'Lokal');
      expect(cloud.saves, 0);
    },
  );

  test('weder Gerät noch Konto haben Antworten: die Fragen kommen', () async {
    final controller = _controller(_DeviceStore(), _FakeCloud());
    expect((await controller.loadPersonalization()).hasDecision, isFalse);
  });

  test('Konto nicht erreichbar: die Fragen kommen, nichts bricht ab', () async {
    final controller = _controller(_DeviceStore(), _BrokenCloud());
    expect((await controller.loadPersonalization()).hasDecision, isFalse);
  });

  test('ohne Einwilligung bleiben die Antworten nur auf dem Gerät', () async {
    final cloud = _FakeCloud();
    final controller = _controller(_DeviceStore(), cloud);

    await controller.savePersonalization(answers);

    expect(cloud.saves, 0);
    expect(cloud.stored, isNull);
  });

  test(
    'Einwilligung später: die Antworten werden dann ins Konto gelegt',
    () async {
      final cloud = _FakeCloud();
      final controller = _controller(_DeviceStore(), cloud);
      await controller.savePersonalization(answers);
      expect(cloud.saves, 0);

      await controller.consent.set(ConsentKind.healthData, true);
      await Future<void>.delayed(Duration.zero);

      expect(cloud.saves, 1);
      expect(cloud.stored?.displayName, 'Max');
    },
  );

  test('mit Einwilligung wird beim Speichern ins Konto geschrieben', () async {
    final cloud = _FakeCloud();
    final controller = _controller(
      _DeviceStore(),
      cloud,
      consents: {ConsentKind.healthData: true},
    );
    await controller.consent.load();

    await controller.savePersonalization(answers);
    await Future<void>.delayed(Duration.zero);

    expect(cloud.saves, 1);
  });

  test(
    'Einwilligung widerrufen: die Antworten verschwinden aus dem Konto',
    () async {
      final cloud = _FakeCloud(answers);
      final controller = _controller(_DeviceStore(), cloud);

      await controller.clearAccountHealthData();

      expect(cloud.deletes, 1);
      expect(cloud.stored, isNull);
    },
  );

  test('Antworten zurücksetzen löscht auch die Kopie im Konto', () async {
    final cloud = _FakeCloud(answers);
    final controller = _controller(_DeviceStore(), cloud);

    await controller.clearPersonalization();

    expect(cloud.deletes, 1);
  });

  test(
    'ein Fehler beim Speichern im Konto stört das Speichern nicht',
    () async {
      final controller = _controller(
        _DeviceStore(),
        _BrokenCloud(),
        consents: {ConsentKind.healthData: true},
      );
      await controller.consent.load();

      await controller.savePersonalization(answers);

      expect(controller.personalization?.displayName, 'Max');
    },
  );
}
