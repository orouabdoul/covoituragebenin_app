$path = "lib\app\modules\principal\passager\messager\views\detail_messager_view.dart"
$content = Get-Content $path -Raw -Encoding UTF8

# Fix header avatar - replace DecorationImage with Image.network
$old = @'
                                Container(
                                  width: responsive.w(48),
                                  height: responsive.w(48),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: AppColors.border,
                                    image: (avatarUrl != null && avatarUrl.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(avatarUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2, color: Color(0xFF00A86B)),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: (avatarUrl == null || avatarUrl.isEmpty)
                                      ? const Icon(Icons.person_rounded, color: AppColors.textGhost)
                                      : null,
                                ),
'@

$new = @'
                                Container(
                                  width: responsive.w(48),
                                  height: responsive.w(48),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: AppColors.border,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2, color: Color(0xFF00A86B)),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, e, s) =>
                                              const Icon(Icons.person_rounded, color: AppColors.textGhost),
                                        )
                                      : const Icon(Icons.person_rounded, color: AppColors.textGhost),
                                ),
'@

# Fix _Avatar widget - replace DecorationImage with Image.network
$old2 = @'
    return Container(
      width: responsive.w(32),
      height: responsive.w(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.border,
        image: (url != null && url.isNotEmpty)
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.person_rounded, size: 18, color: AppColors.textGhost)
          : null,
    );
'@

$new2 = @'
    return Container(
      width: responsive.w(32),
      height: responsive.w(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.border,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) =>
                  const Icon(Icons.person_rounded, size: 18, color: AppColors.textGhost),
            )
          : const Icon(Icons.person_rounded, size: 18, color: AppColors.textGhost),
    );
'@

$content = $content.Replace($old, $new)
$content = $content.Replace($old2, $new2)
[System.IO.File]::WriteAllText((Resolve-Path $path).Path, $content, [System.Text.Encoding]::UTF8)
Write-Host "Done"
