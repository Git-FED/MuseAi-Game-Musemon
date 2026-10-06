# Save contract
The markdown wrapper contains one fenced json block. issue-save returns the complete normalized_payload; export it unchanged.
Canonical serialization sorts object keys recursively; array order is preserved. The SHA-256 input excludes only top-level revision_no and server_signature. HMAC-SHA256 signs that hash. Verification also checks the exact recorded revision and signature.
Normal request: {"payload":{"stats":{"map_id":"hotel_iot_f1","x_coord":8,"y_coord":12}}}.
First/recovery request: {"first_save":true,"starting_wing":"iot"}. Other wings: lounge, mainframe. An existing profile is retained; recovery issues a new revision without resetting progression.
Issue response: {ok,revision_no,payload_hash,server_signature,normalized_payload,player}.
Verify request: {payload:<entire exported JSON>}. Response: {ok,status,revision_no,player,save}; failures have status or error/reason.
Progression and companion data come from the database. Inventory is empty in this prototype, not client-granted. Position is cosmetic and bounded, not gameplay proof. Old revisions reject softly; mismatches never automatically ban.
SERVER_SAVE_SECRET rotation invalidates the current verifier's old signatures; recover/export new saves afterward.
