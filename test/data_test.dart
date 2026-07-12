import 'package:flutter_test/flutter_test.dart';
import 'package:hory_nex/core/data/haiti_locations.dart';
import 'package:hory_nex/core/data/filieres.dart';
import 'package:hory_nex/repositories/payment_repository.dart';

void main() {
  group('Données Haïti', () {
    test('contient exactement 10 départements', () {
      expect(HaitiLocations.departements.length, 10);
    });

    test('chaque département possède au moins une commune', () {
      for (final dep in HaitiLocations.departements) {
        expect(HaitiLocations.communesDe(dep), isNotEmpty,
            reason: 'Le département $dep n\'a aucune commune');
      }
    });

    test('le département Nord contient Cap-Haïtien', () {
      expect(HaitiLocations.communesDe('Nord'), contains('Cap-Haïtien'));
    });
  });

  group('Filières PREPAC', () {
    test('contient 3 axes', () {
      expect(Filieres.axes.length, 3);
    });

    test('chaque axe possède des filières', () {
      for (final axe in Filieres.axes) {
        expect(Filieres.filieresDe(axe), isNotEmpty);
      }
    });
  });

  group('Calcul du solde', () {
    test('payé intégralement', () {
      const b = StudentBalance(montantPrepac: 1000, totalPaye: 1000);
      expect(b.solde, 0);
      expect(b.status.label, 'Payé');
    });

    test('partiellement payé', () {
      const b = StudentBalance(montantPrepac: 1000, totalPaye: 400);
      expect(b.solde, 600);
      expect(b.status.label, 'Partiellement payé');
    });

    test('non payé', () {
      const b = StudentBalance(montantPrepac: 1000, totalPaye: 0);
      expect(b.status.label, 'Non payé');
    });
  });
}
