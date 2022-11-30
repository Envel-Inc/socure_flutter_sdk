@JS()
library socure;

import 'package:js/js.dart';

@JS()
class Devicer {
	external dynamic run(SocureFPOptions options, Function(SocureRunResponse) fn);
}

@JS()
class SocureDocV {
	external dynamic init(String publicKey, String embedDiv, SocureDocVConfig config);
	
	/// [processEnum] values:
	///   - 1: Complete the document upload through the Web SDK and control the document verification process on your side for greater control and process modularity. The success callback will contain the success response for the file upload process only.
	///   - 2: Complete the document upload and document verification process with Socure and receive the transaction details along with reason codes to make the final call. The success callback will contain the document verification response along with reason codes, and document extracted data if provisioned.
	///   - 3: Complete the document upload, document verification, and phone risk in a single transaction receiving a consolidated transaction response. The success callback will contain the document verification and Phone RiskScore response along with reason codes, and document extracted data if provisioned. The mobile number field is mandatory for the process.
	external dynamic start(int processEnum, String? mobileNumber);
}

@JS('SocureInitializer.init')
external dynamic initSocureDocV(String publicKey);

// Cleans up the token stored in the browser memory.
@JS('Socure.cleanup')
external dynamic socureCleanup();

// It calls cleanup() function internally and also unmount the Web SDK application from the browser and invalidate the token.
@JS('Socure.reset')
external dynamic socureReset();

@JS()
@anonymous
class SocureFPOptions {
	external String get publicKey;
	external bool get userConsent;
	external String get context;
	
	// Must have an unnamed factory constructor with named arguments.
	external factory SocureFPOptions({String publicKey, bool userConsent, String context});
}

@JS()
@anonymous
class SocureRunResponse {
	/// The values for the result are either Captured or Ignored. Ignored is returned when the consent is set as false when sending the request.
	external String get result;
	external String? get sessionId;
	
	// Must have an unnamed factory constructor with named arguments.
	external factory SocureRunResponse({String? sessionId, String? result});
}

@JS()
@anonymous
class SocureDocVConfig {
	external bool get qrCodeNeeded;
	external Function(String) get onProgress; /// WAITING_FOR_REDIRECT_METHOD, WAITING_FOR_USER_TO_REDIRECT, WAITING_FOR_UPLOAD, DOCUMENTS_UPLOADED, VERIFYING, VERIFICATION_COMPLETE, VERIFICATION_ERROR
	external Function(SocureDocResponse) get onSuccess;
	external Function(SocureDocResponse) get onError;
	
	// Must have an unnamed factory constructor with named arguments.
	external factory SocureDocVConfig({bool qrCodeNeeded, Function(String) onProgress, Function(SocureDocResponse) onSuccess, Function(SocureDocResponse) onError});
}

@JS()
@anonymous
class SocureDocResponse {
	external String get eventId;
	external String get status; // VERIFICATION_COMPLETE, VERIFICATION_ERROR,
	external int get verificationLevel;
	external String get mobileNumber;
	external String get key;
	external String get referenceId;
	external String? get documentUuid;
	external VerifyResult? get verifyResult;
	
	// Must have an unnamed factory constructor with named arguments.
	external factory SocureDocResponse({String eventId, String status, String documentUuid, int verificationLevel, String mobileNumber, String key, String referenceId, VerifyResult? verifyResult});
}

@JS()
@anonymous
class VerifyResult {
	external String get referenceId;
	external VerifyResultDocumentVerification get documentVerification;
	
	// Must have an unnamed factory constructor with named arguments.
	external factory VerifyResult({String referenceId, VerifyResultDocumentVerification documentVerification});
}

@JS()
@anonymous
class VerifyResultDocumentVerification {
	external List<String>? get reasonCodes;
	external DocumentType get documentType;
	external Decision? get decision;
	
	external factory VerifyResultDocumentVerification({String? referenceId, DocumentType documentType, Decision? decision});
}

@JS()
@anonymous
class DocumentType {
	external String get type; // Drivers License
	external String get country; // US
	external String? get state; // CA
	
	external factory DocumentType({String type, String country, String? state});
}

@JS()
@anonymous
class Decision {
	external String get name; // lenient
	external String get value; // accept
	
	external factory Decision({String name, String value});
}

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
	external Devicer get devicer;
	external String get socurePublicKey;
}