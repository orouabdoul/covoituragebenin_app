import sys

driver_path = r"C:\Users\HP_PC\StudioProjects\covoiturage_benin_app\lib\app\modules\principal\driver\messager\views\detail_messager_view.dart"

with open(driver_path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'class _ImageWidget extends StatelessWidget' in content:
    print("_ImageWidget ALREADY EXISTS - no action needed")
    sys.exit(0)

new_class = r"""class _ImageWidget extends StatelessWidget {
  const _ImageWidget({
    required this.url,
    required this.isOutgoing,
    required this.responsive,
  });

  final String url;
  final bool isOutgoing;
  final AppResponsive responsive;

  bool get _isLocal =>
      !url.startsWith('http://') && !url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final path =
        _isLocal && url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;

    Widget img;
    if (_isLocal) {
      img = Image.file(
        File(path),
        width: r.w(220),
        height: r.h(160),
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _broken(r),
      );
    } else {
      img = Image.network(
        url,
        width: r.w(220),
        height: r.h(160),
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _broken(r),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: r.w(220),
            height: r.h(160),
            child: Center(
              child: CircularProgressIndicator(
                color: isOutgoing ? Colors.white : AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius(10)),
      child: Stack(
        children: [
          img,
          if (_isLocal)
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
  }

  Widget _broken(AppResponsive r) => Container(
        width: r.w(220),
        height: r.h(80),
        color: isOutgoing ? Colors.white24 : AppColors.border,
        child: Icon(Icons.broken_image_rounded,
            color: isOutgoing ? Colors.white54 : AppColors.textGhost),
      );
}

"""

anchor = "class _Avatar extends StatelessWidget {"
if anchor not in content:
    print("ERROR: anchor 'class _Avatar extends StatelessWidget {' not found")
    sys.exit(1)

updated = content.replace(anchor, new_class + anchor, 1)
with open(driver_path, 'w', encoding='utf-8') as f:
    f.write(updated)
print("SUCCESS: _ImageWidget class inserted before _Avatar in driver view")
