import 'package:nfc_manager/nfc_manager.dart';

class nfcBackend {
  String extractTagId(NfcTag tag) {
    // Try to extract the tag ID from different sections of the tag data
    String tagId = _bytesToHex(tag.data['nfca']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcb']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcf']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['nfcv']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['mifareclassic']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['mifareultralight']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['ndefformatable']?['identifier'] ?? []) ??
        _bytesToHex(tag.data['isodep']?['identifier'] ?? []) ??
        ''; // Default to an empty string if none found

    return tagId.toUpperCase();
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }
}
