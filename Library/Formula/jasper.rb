require 'formula'

class Jasper < Formula
  desc "Library for manipulating JPEG-2000 images"
  homepage 'http://www.ece.uvic.ca/~frodo/jasper/'
  url 'http://download.osgeo.org/gdal/jasper-1.900.1.uuid.tar.gz'
  sha1 'bbf30168ceae74d78e28039972657a90799e68d3'
  version '1.900.1'

  bottle do
    cellar :any
    revision 1
    sha1 "7fd9acebd672cdb1bda21c709d3e59a7ff350a4f" => :yosemite
    sha1 "4ea4b6abe67ccd2727b33b545de6537d196f8253" => :mavericks
    sha1 "34fb2f4888da21b43ecb7fd8e190e4b66e42a3a1" => :mountain_lion
  end

  option :universal

  depends_on 'jpeg'

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  # The following patch fixes a bug (still in upstream as of jasper 1.900.1)
  # where an assertion fails when Jasper is fed certain JPEG-2000 files with
  # an alpha channel. See:
  # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=469786
  patch :DATA

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-shared",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make install"
  end
end

__END__
diff --git a/src/libjasper/jpc/jpc_dec.c b/src/libjasper/jpc/jpc_dec.c
index fa72a0e..1f4845f 100644
--- a/src/libjasper/jpc/jpc_dec.c
+++ b/src/libjasper/jpc/jpc_dec.c
@@ -1069,12 +1069,18 @@ static int jpc_dec_tiledecode(jpc_dec_t *dec, jpc_dec_tile_t *tile)
	/* Apply an inverse intercomponent transform if necessary. */
	switch (tile->cp->mctid) {
	case JPC_MCT_RCT:
-		assert(dec->numcomps == 3);
+		if (dec->numcomps != 3 && dec->numcomps != 4) {
+			jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+			return -1;
+		}
		jpc_irct(tile->tcomps[0].data, tile->tcomps[1].data,
		  tile->tcomps[2].data);
		break;
	case JPC_MCT_ICT:
-		assert(dec->numcomps == 3);
+		if (dec->numcomps != 3 && dec->numcomps != 4) {
+			jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+			return -1;
+		}
		jpc_iict(tile->tcomps[0].data, tile->tcomps[1].data,
		  tile->tcomps[2].data);
		break;
