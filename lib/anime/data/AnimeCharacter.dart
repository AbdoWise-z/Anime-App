class AnimeCharacter{
  final int char_id;
  final String character_name;
  final int character_role;
  final int va_id;
  final int anime_id;
  final String char_img_link;
  final String va_name;
  final String va_img_link;
  final String va_birth_date;

  const AnimeCharacter({
    required this.char_id,
    required this.character_name,
    required this.character_role,
    required this.va_id,
    required this.anime_id,
    required this.char_img_link,
    required this.va_name,
    required this.va_img_link,
    required this.va_birth_date,
  });
}