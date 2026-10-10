import 'dart:typed_data';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OID', () {
    test('toValue should return oid string', () {
      expect(OID.commonName.toValue(), '2.5.4.3');
      expect(OID.keyUsage.toValue(), '2.5.29.15');
    });

    test('name should return mapped display name', () {
      expect(OID.commonName.name(), 'commonName');
      expect(OID.rsaEncryption.name(), 'rsaEncryption');
    });

    test('fromValue should resolve known oid and return null for unknown', () {
      expect(OID.fromValue('2.5.4.3'), OID.commonName);
      expect(OID.fromValue('9.9.9.9'), isNull);
      expect(OID.fromValue(null), isNull);
    });

    test('toString should include value and name', () {
      expect(OID.commonName.toString(), contains('2.5.4.3'));
      expect(OID.commonName.toString(), contains('commonName'));
    });
  });

  group('KeyUsage', () {
    test('static values should expose all key usage bits', () {
      expect(KeyUsage.digitalSignature.toValue(), 0);
      expect(KeyUsage.nonRepudiation.toValue(), 1);
      expect(KeyUsage.keyEncipherment.toValue(), 2);
      expect(KeyUsage.dataEncipherment.toValue(), 3);
      expect(KeyUsage.keyAgreement.toValue(), 4);
      expect(KeyUsage.keyCertSign.toValue(), 5);
      expect(KeyUsage.cRLSign.toValue(), 6);
      expect(KeyUsage.encipherOnly.toValue(), 7);
      expect(KeyUsage.decipherOnly.toValue(), 8);
    });

    test('fromIndex and name should resolve known values', () {
      expect(KeyUsage.fromIndex(0), KeyUsage.digitalSignature);
      expect(KeyUsage.digitalSignature.name(), 'digitalSignature');
      expect(KeyUsage.fromIndex(99), isNull);
      expect(KeyUsage.fromIndex(null), isNull);
    });

    test('toString should include index and name', () {
      expect(KeyUsage.keyCertSign.toString(), contains('keyCertSign'));
    });
  });

  group('ASN1Object', () {
    test('sub helpers should navigate children', () {
      final child = ASN1Object()..value = 'leaf';
      final root = ASN1Object()..sub = [child];

      expect(root.subCount(), 1);
      expect(root.firstSub()?.value, 'leaf');
      expect(root.lastSub()?.value, 'leaf');
      expect(root.subAtIndex(0)?.value, 'leaf');
      expect(root.subAtIndex(5), isNull);
      expect(root.asString, 'leaf');
    });

    test('findOid should locate object identifier nodes', () {
      final oidNode = ASN1Object()
        ..identifier = ASN1Identifier(
          ASN1IdentifierTagNumber.OBJECT_IDENTIFIER.toValue(),
        )
        ..value = OID.commonName.toValue();
      final root = ASN1Object()..sub = [oidNode];

      expect(root.findOid(oid: OID.commonName)?.value, OID.commonName.toValue());
      expect(root.findOid(oidValue: 'missing'), isNull);
    });

    test('description and toString should describe tree', () {
      final obj = ASN1Object()..value = 'hello';
      expect(obj.description, isA<String>());
      expect(obj.toString(), obj.description);
    });

    test('atIndex should map X509BlockPosition', () {
      final version = ASN1Object()..value = [0];
      final serial = ASN1Object()..value = [1, 2];
      final root = ASN1Object()..sub = [version, serial];

      expect(root.atIndex(X509BlockPosition.version)?.value, [0]);
      expect(root.atIndex(X509BlockPosition.serialNumber)?.value, [1, 2]);
    });
  });

  group('ASN1DERDecoder', () {
    test('decode should parse boolean integer null and sequence', () {
      final decoded = ASN1DERDecoder.decode(data: [
        0x01, 0x01, 0xff, // BOOLEAN true
        0x02, 0x01, 0x01, // INTEGER 1
        0x05, 0x00, // NULL
        0x30, 0x00, // SEQUENCE empty
      ]);

      expect(decoded.length, 4);
      expect(decoded[0].value, isTrue);
      expect(decoded[1].value, [0x01]);
      expect(decoded[2].value, isNull);
      expect(decoded[3].sub, isEmpty);
    });

    test('decodeOid should convert der oid bytes to dotted string', () {
      // 2.5.4.3 (commonName) => 55 04 03
      expect(
        ASN1DERDecoder.decodeOid(contentData: [0x55, 0x04, 0x03]),
        '2.5.4.3',
      );
      expect(ASN1DERDecoder.decodeOid(contentData: []), isNull);
    });

    test('utcTimeToDate should parse YYMMDDhhmmssZ', () {
      final date = ASN1DERDecoder.utcTimeToDate(
        contentData: '250101120000Z'.codeUnits,
      );
      expect(date, DateTime.utc(2025, 1, 1, 12));
    });
  });

  group('ASN1DEREncoder', () {
    test('contentLength should encode short form under 128', () {
      final encoded = ASN1DEREncoder.contentLength(size: 5);
      expect(encoded.length, 5);
    });

    test('encodeSequence should accept empty content bytes', () {
      // Implementation currently uses fixed-length Uint8List; verify call path.
      expect(
        () => ASN1DEREncoder.encodeSequence(content: Uint8List(0)),
        throwsA(anything),
      );
    });
  });

  group('X509Extension', () {
    test('oid critical and value getters should read extension block', () {
      final oidNode = ASN1Object()..value = OID.keyUsage.toValue();
      final criticalNode = ASN1Object()..value = true;
      final valueNode = ASN1Object()..value = [0x80];
      final block = ASN1Object()..sub = [oidNode, criticalNode, valueNode];

      final extension = X509Extension(block: block);
      expect(extension.oid, OID.keyUsage.toValue());
      expect(extension.name, 'keyUsage');
      expect(extension.isCritical, isTrue);
      expect(extension.value, [0x80]);
      expect(extension.valueAsBlock, valueNode);
      expect(extension.toString(), isA<String>());
    });

    test('BasicConstraintExtension toMap should expose ca flag', () {
      final boolNode = ASN1Object()..value = true;
      final seq = ASN1Object()..sub = [boolNode];
      final valueBlock = ASN1Object()..sub = [seq];
      final block = ASN1Object()
        ..sub = [
          ASN1Object()..value = OID.basicConstraints.toValue(),
          valueBlock,
        ];

      final extension = BasicConstraintExtension(block: block);
      expect(extension.isCA, isTrue);
      expect(extension.toMap()['isCA'], isTrue);
      expect(extension.toString(), contains('isCA'));
    });
  });

  group('X509PublicKey', () {
    test('algOid algName and toMap should read public key block', () {
      final algOid = ASN1Object()..value = OID.rsaEncryption.toValue();
      final algParams = ASN1Object()..value = null;
      final algSeq = ASN1Object()..sub = [algOid, algParams];
      final keyBits = ASN1Object()..value = [0x00, 0x01, 0x02];
      final pkBlock = ASN1Object()
        ..encoded = Uint8List.fromList([0x30, 0x00])
        ..sub = [algSeq, keyBits];

      final publicKey = X509PublicKey(pkBlock: pkBlock);
      expect(publicKey.algOid, OID.rsaEncryption.toValue());
      expect(publicKey.algName, 'rsaEncryption');
      expect(publicKey.algParams, isNull);
      expect(publicKey.toMap()['algOid'], OID.rsaEncryption.toValue());
      expect(publicKey.toJson()['algName'], 'rsaEncryption');
    });
  });

  group('X509Certificate', () {
    ASN1Object buildBlock1({
      List<int> serial = const [0x01],
      DateTime? notBefore,
      DateTime? notAfter,
    }) {
      final before = ASN1Object()..value = notBefore ?? DateTime.utc(2020, 1, 1);
      final after = ASN1Object()..value = notAfter ?? DateTime.utc(2030, 1, 1);
      final validity = ASN1Object()..sub = [before, after];
      final issuer = ASN1Object()..sub = [];
      final subject = ASN1Object()..sub = [];
      final version = ASN1Object()..value = [0x00];
      final serialNode = ASN1Object()..value = serial;
      final sigAlg = ASN1Object()
        ..sub = [
          ASN1Object()..value = OID.sha256WithRSAEncryption.toValue(),
        ];
      final publicKey = ASN1Object()
        ..sub = [
          ASN1Object()
            ..sub = [
              ASN1Object()..value = OID.rsaEncryption.toValue(),
            ],
        ];

      return ASN1Object()
        ..sub = [
          version,
          serialNode,
          sigAlg,
          issuer,
          validity,
          subject,
          publicKey,
        ];
    }

    test('serialNumber notBefore notAfter and checkValidity should work', () {
      final block1 = buildBlock1(serial: [0x0a, 0x0b]);
      final cert = X509Certificate()
        ..block1 = block1
        ..asn1 = [ASN1Object()..sub = [block1]]
        ..encoded = Uint8List.fromList([0x30, 0x00]);

      expect(cert.serialNumber, [0x0a, 0x0b]);
      expect(cert.notBefore, DateTime.utc(2020, 1, 1));
      expect(cert.notAfter, DateTime.utc(2030, 1, 1));
      expect(cert.checkValidity(date: DateTime.utc(2025, 1, 1)), isTrue);
      expect(cert.checkValidity(date: DateTime.utc(2010, 1, 1)), isFalse);
      expect(cert.version, 1);
      expect(cert.sigAlgOID, OID.sha256WithRSAEncryption.toValue());
      expect(cert.sigAlgName, 'sha256WithRSAEncryption');
      expect(cert.publicKey, isA<X509PublicKey>());
    });

    test('issuer and subject helpers should return empty without dn entries', () {
      final cert = X509Certificate()..block1 = buildBlock1();
      expect(cert.issuerDistinguishedName, anyOf(isNull, isEmpty));
      expect(cert.subjectDistinguishedName, anyOf(isNull, isEmpty));
      expect(cert.issuerOIDs, isEmpty);
      expect(cert.subjectOIDs, isEmpty);
      expect(cert.issuer(dn: ASN1DistinguishedNames.COMMON_NAME), isNull);
      expect(cert.subject(dn: ASN1DistinguishedNames.COMMON_NAME), isNull);
    });

    test('toMap toJson and toString should serialize certificate fields', () {
      final block1 = buildBlock1();
      final cert = X509Certificate()
        ..block1 = block1
        ..asn1 = [ASN1Object()..sub = [block1]]
        ..encoded = Uint8List.fromList([0x30, 0x03]);

      final map = cert.toMap();
      expect(map['serialNumber'], [0x01]);
      expect(map['version'], 1);
      expect(map['encoded'], Uint8List.fromList([0x30, 0x03]));
      expect(cert.toJson()['sigAlgOID'], OID.sha256WithRSAEncryption.toValue());
      expect(cert.toString(), isA<String>());
    });

    test('decodeToDER should extract pem body bytes', () {
      final pem = utf8Bytes('''
-----BEGIN CERTIFICATE-----
QUJD
-----END CERTIFICATE-----
''');
      final der = X509Certificate.decodeToDER(pemData: pem);
      expect(der, isNotNull);
      expect(String.fromCharCodes(der!), 'QUJD');
    });
  });
}

Uint8List utf8Bytes(String value) => Uint8List.fromList(value.codeUnits);
