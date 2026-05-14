import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts" / "work_jiang"))

from asr_light_clean import light_clean
from asr_transcript_replacements import apply_replacements
from normalize_lecture_transcript_asr import normalize_text


def test_light_clean_preserves_words_and_normalizes_spacing():
    assert light_clean("one   two\r\n\r\n\r\nthree") == "one two\n\nthree\n"


def test_apply_replacements_accepts_targeted_patterns():
    text = apply_replacements("Marx said dialectical material ism.", [(r"material ism", "materialism")])
    assert text == "Marx said dialectical materialism."


def test_normalize_text_is_conservative_without_replacements():
    assert normalize_text("Predictive   History") == "Predictive History\n"
