# Agent Instructions

1. `/sethome` is idempotent.
2. Home Group state must be persistent.
3. Do not ask for `/sethome` when state is READY and identity/chat are valid.
4. Setup state and command routing are separate subsystems.
5. `/entry` must reach its handler after authorization.
6. Telegram User ID is the identity; username is not.
7. Every trading action is authorization + validation + risk checked.
8. Never claim order success without MT5 read-back.
9. If state is inconsistent, report the exact failing stage and repair it.
10. Do not blind retry.
