import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const maxAvatarSourceBytes = 8 * 1024 * 1024;
const maxAvatarUploadBytes = 1024 * 1024;

class AvatarImageException implements Exception {
  const AvatarImageException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PreparedAvatarImage {
  const PreparedAvatarImage(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final int width;
  final int height;
}

class AvatarCropRequest {
  const AvatarCropRequest({
    required this.image,
    this.zoom = 1,
    this.horizontal = 0.5,
    this.vertical = 0.5,
  });
  final PreparedAvatarImage image;
  final double zoom;
  final double horizontal;
  final double vertical;
}

/// Validates dimensions before decoding pixel buffers. Only the first frame of
/// a JPEG or PNG is accepted, then orientation is baked and metadata discarded.
PreparedAvatarImage prepareAvatarImage(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxAvatarSourceBytes) {
    throw AvatarImageException(L10n.current.profileChooseAnImageNoLargerThan8);
  }
  try {
    final img.Decoder decoder;
    if (img.JpegDecoder().isValidFile(bytes)) {
      decoder = img.JpegDecoder();
    } else if (img.PngDecoder().isValidFile(bytes)) {
      decoder = img.PngDecoder();
    } else {
      throw AvatarImageException(
        L10n.current.profilePleaseChooseAJpgOrPngImage,
      );
    }
    final info = decoder.startDecode(bytes);
    if (info == null || info.width < 1 || info.height < 1) {
      throw AvatarImageException(L10n.current.profileThisImageCouldNotBeOpened);
    }
    if (info.width > 10000 ||
        info.height > 10000 ||
        info.width * info.height > 24000000) {
      throw AvatarImageException(
        L10n.current.profileTheImageIsVeryLargeChooseA,
      );
    }
    final decoded = decoder.decodeFrame(0);
    if (decoded == null) {
      throw AvatarImageException(L10n.current.profileThisImageCouldNotBeOpened);
    }
    var image = img.bakeOrientation(decoded);
    if (math.max(image.width, image.height) > 2048) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 2048 : null,
        height: image.height > image.width ? 2048 : null,
        interpolation: img.Interpolation.average,
      );
    }
    // A fresh RGB buffer drops EXIF, GPS, comments and embedded profiles. PNG
    // transparency is composited onto the neutral app surface before JPEG.
    final clean = img.Image(width: image.width, height: image.height);
    img.fill(clean, color: img.ColorRgb8(27, 30, 28));
    img.compositeImage(clean, image);
    return PreparedAvatarImage(
      Uint8List.fromList(img.encodeJpg(clean, quality: 92)),
      clean.width,
      clean.height,
    );
  } on AvatarImageException {
    rethrow;
  } catch (_) {
    throw AvatarImageException(L10n.current.profileThisImageCouldNotBeOpened);
  }
}

Uint8List cropAvatarImage(AvatarCropRequest request) {
  if (!request.zoom.isFinite ||
      !request.horizontal.isFinite ||
      !request.vertical.isFinite) {
    throw AvatarImageException(L10n.current.profileSelectTheCropAgain);
  }
  final image = img.decodeJpg(request.image.bytes);
  if (image == null) {
    throw AvatarImageException(L10n.current.profilePleaseChooseTheImageAgain);
  }
  final zoom = request.zoom.clamp(1.0, 3.0);
  final side = math.max(
    1,
    (math.min(image.width, image.height) / zoom).round(),
  );
  final x = ((image.width - side) * request.horizontal.clamp(0.0, 1.0)).round();
  final y = ((image.height - side) * request.vertical.clamp(0.0, 1.0)).round();
  final square = img.copyCrop(image, x: x, y: y, width: side, height: side);
  final resized = img.copyResize(
    square,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.average,
  );
  final clean = img.Image(width: 512, height: 512);
  img.compositeImage(clean, resized);
  final jpeg = Uint8List.fromList(img.encodeJpg(clean, quality: 85));
  if (jpeg.length > maxAvatarUploadBytes) {
    throw AvatarImageException(L10n.current.profileTheImageCouldNotBeResized);
  }
  return jpeg;
}
