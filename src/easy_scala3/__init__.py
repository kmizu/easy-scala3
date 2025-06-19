"""
やさしいScala 3入門 - プログラミング完全初心者のためのScala 3入門書

この書籍は、プログラミングを全く知らない初心者の方が、
Scala 3という現代的な言語を通じてプログラミングを学ぶための入門書です。
"""

__version__ = "1.0.0"
__author__ = "Scala 3入門編集部"
__email__ = "info@example.com"

# パッケージレベルのexports
from .cli import serve, build

__all__ = ["serve", "build"]