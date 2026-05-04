<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# If you review the 2 previous threads we made some significant technical iterations and we made a decision to use WhisperKit can you summarize the technical decisions and the decision around choosing WhisperKit in a short document that can act as a supplement to the PRD.

Yes — here is a short PRD supplement that captures the main technical decisions and the rationale for choosing WhisperKit. It reflects the recent iteration toward an iOS voice-input architecture optimized for intent accuracy, speed, privacy, and cost.[^1][^2]

## Purpose

This supplement defines the current voice transcription direction for Sift and records the decisions made during the recent technical iteration. The product goal is not perfect dictation formatting, but reliable capture of user intent with fast enough feedback to feel natural in the app.[^2][^1]

## Technical decisions

The app will use an iOS-native, on-device speech pipeline rather than making cloud transcription the default path. The evaluation criteria were prioritized as: 1) transcription accuracy for intent capture, 2) transcription speed, and 3) operating cost.[^2][^1]

For the near-term implementation, transcription is in scope and downstream LLM processing is explicitly out of scope for the prototype and validation phase. The first deliverable is a lightweight internal test app designed to measure transcript quality, latency, and overall interaction flow rather than a polished end-user experience.[^3][^4]

## WhisperKit decision

WhisperKit was selected as the primary transcription engine, with Deepgram as the main runner-up. The main reason is that WhisperKit best matched the product priorities by combining strong transcription quality with low latency and no per-minute API cost in the open-source deployment model.[^5][^1]

This choice also fits the privacy direction of the product because WhisperKit is designed for on-device speech recognition on Apple devices, which reduces the need to send raw audio to external services. WhisperKit is made by Argmax, and the project has been open-sourced under the MIT license, which supports commercial use without a mandatory upgrade from prototype to production.[^6][^7][^8][^9][^5]

## Why WhisperKit

WhisperKit is specifically optimized for real-time streaming transcription on Apple devices, and published benchmarks report both very low latency and very high accuracy relative to several cloud competitors. Its architecture also supports a streaming UX with both low-latency hypothesis text and more stable confirmed text, which maps well to a voice-first product experience.[^10][^6]

Compared with cloud-first alternatives, WhisperKit gives better long-run unit economics for high-usage scenarios because there is no inherent per-minute transcription fee in the open-source version, though engineering and device-performance costs still remain. Compared with Apple’s native APIs alone, it was favored because the decision process weighted transcript quality and intent capture more heavily than minimum implementation effort.[^8][^1][^2][^5]

## Product implications

The MVP should start with the free/open-source WhisperKit path and only revisit paid or Pro features if real blockers appear around continuous streaming, diarization, latency, or deployment complexity at scale. Success for this phase means most spoken inputs preserve intended meaning, response time feels natural, and the team can clearly identify failure patterns before expanding scope.[^11][^4][^3][^5]

A compact version for direct PRD insertion could be: “Sift will use WhisperKit as the default iOS transcription engine for MVP validation because it best satisfies our priority order of intent-level accuracy, speed, privacy, and cost. We are intentionally testing transcription quality and UX flow first, while keeping LLM post-processing out of scope until the speech layer is validated.”[^4][^1][^3][^5]

Would you like this rewritten into a more formal PRD style with headings like “Decision,” “Rationale,” “Scope,” and “Risks”?
<span style="display:none">[^12][^13][^14][^15][^16][^17][^18][^19][^20][^21][^22][^23]</span>

<div align="center">⁂</div>

[^1]: https://www.perplexity.ai/search/0034d0e5-d8f8-4456-aac0-5c7b5c29ece0

[^2]: https://www.perplexity.ai/search/a6da19a8-51c5-46f5-b9e1-7a0e219a2b72

[^3]: https://www.perplexity.ai/search/765913cb-c0d6-4169-8152-38b3ee4d5455

[^4]: https://www.perplexity.ai/search/e38a13d0-13e1-4218-a638-b40f73da6c14

[^5]: https://www.perplexity.ai/search/6c97314b-f428-4de9-a1e9-f6fd53de7877

[^6]: https://arxiv.org/html/2507.10860v1

[^7]: https://www.argmaxinc.com/blog/whisperkit

[^8]: https://www.perplexity.ai/search/3a8e1f98-08f5-4ba1-a3c6-58c58d97a02b

[^9]: https://www.perplexity.ai/search/135fd308-e497-48e7-818b-6ca22ba10919

[^10]: https://arxiv.org/abs/2507.10860

[^11]: https://www.perplexity.ai/search/74391554-ccbd-4a1d-b49d-cbc1deb00c8c

[^12]: https://www.emergentmind.com/papers/2507.10860

[^13]: https://yangfei.me/posts/whisperkit/

[^14]: https://huggingface.co/papers?q=EMMA+MT-ASR+benchmark

[^15]: https://macwhisper.helpscoutdocs.com/article/29-switching-to-a-whisperkit-model

[^16]: https://github.com/argmaxinc/WhisperKitAndroid

[^17]: https://theses.hal.science/tel-00643729v1/file/synthese-hdr.pdf

[^18]: https://www.linkedin.com/pulse/101-whisper-vs-whispercpp-whisperkit-whats-difference-jove-zhong-xbtvc

[^19]: https://openreview.net/pdf?id=6lC3MPFbVg

[^20]: https://www.facebook.com/groups/EXPERIMENTALAIRCRAFT/posts/1155362775067122/

[^21]: https://openreview.net/forum?id=6lC3MPFbVg

[^22]: https://www.mintlify.com/argmaxinc/WhisperKit/introduction

[^23]: http://kydceramics.com/upload/userfiles/files/xefogudizojo_tonovopobetape.pdf

