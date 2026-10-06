# Security notes
No private keys are included. Rotate any secret previously pasted in the conversation before deployment.
Auth JWTs are validated inside Edge Functions. Invite and branch-ban checks run before issuing/verifying saves. Signatures authenticate exported snapshots, not gameplay accomplishments. No XP-granting gameplay is implemented.
Realtime movement is client-reported cosmetic presence, not authenticated anti-cheat movement; public channels can be observed/spoofed by someone with project access. Before private production multiplayer, add private Realtime authorization and validate sender identity. Do not use this channel for rewards, trades, or combat.
The initial migration is not an audit/removal of every legacy function or policy. Older permissive SECURITY DEFINER RPCs must be separately reviewed/revoked.
Save mismatch creates a review request; it never issues an automatic ban. Current save recovery is allowed after email authentication.
Native session callback URLs contain credentials; never share them with other players or paste them into chats.
