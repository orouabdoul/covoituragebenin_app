import sys

passager_path = r"C:\Users\HP_PC\StudioProjects\covoiturage_benin_app\lib\app\modules\principal\passager\messager\views\detail_messager_view.dart"

with open(passager_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        child: Image.network(
          url,
          width: responsive.w(220),
          height: responsive.h(160),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            width: responsive.w(220),
            height: responsive.h(80),
            color: isIncoming ? AppColors.border : Colors.white24,
            child: Icon(Icons.broken_image_rounded,
                color: isIncoming ? AppColors.textGhost : Colors.white54),
          ),
        ),
      );
    }"""

new_block = r"""    if (isImage) {
      final isLocal = !url.startsWith('http://') && !url.startsWith('https://');
      final path = isLocal && url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
      final broken = Container(
        width: responsive.w(220),
        height: responsive.h(80),
        color: isIncoming ? AppColors.border : Colors.white24,
        child: Icon(Icons.broken_image_rounded,
            color: isIncoming ? AppColors.textGhost : Colors.white54),
      );
      Widget img;
      if (isLocal) {
        img = Image.file(
          File(path),
          width: responsive.w(220),
          height: responsive.h(160),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => broken,
        );
      } else {
        img = Image.network(
          url,
          width: responsive.w(220),
          height: responsive.h(160),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => broken,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: responsive.w(220),
              height: responsive.h(160),
              child: Center(
                child: CircularProgressIndicator(
                  color: isIncoming ? AppColors.primary : Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(responsive.radius(10)),
        child: Stack(
          children: [
            img,
            if (isLocal)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      );
    }"""

if old_block not in content:
    print("ERROR: old isImage block not found in passager view")
    # Print a snippet around the area to debug
    idx = content.find('if (isImage)')
    if idx >= 0:
        print("Found 'if (isImage)' at index", idx)
        print("Context:", repr(content[idx:idx+300]))
    sys.exit(1)

updated = content.replace(old_block, new_block, 1)
with open(passager_path, 'w', encoding='utf-8') as f:
    f.write(updated)
print("SUCCESS: isImage block replaced in passager view with local/remote logic")

# Check dart:io import
if "import 'dart:io';" in updated:
    print("dart:io already imported - OK")
else:
    print("WARNING: dart:io NOT imported in passager view")
