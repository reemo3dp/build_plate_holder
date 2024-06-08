OPENSCAD ?= openscad

.PHONY: all clean

SIZES := 120mm 250mm 300mm 350mm
NUMBERS := 2 3 4 5

all: $(foreach size,$(SIZES),\
		$(foreach number,$(NUMBERS),stls/skadis_$(size)_$(number).stl)) \
	 $(foreach size,$(SIZES),\
	 	$(foreach number,$(NUMBERS),stls/standing_$(size)_$(number).stl))
	$(MAKE) README.md


clean:
	rm -rf stls/

.PHONY: README.md
README.md: stls/*.stl
	@echo "# SKÅDIS Build Plate Holder" > README.md
	@echo "This is a customizable build plate holder for the IKEA SKÅDIS pegboard system." >> README.md
	@echo "" >> README.md


build_plate_holder.scad: skadis_base.scad chamfer.scad

stls/skadis_%.stl: build_plate_holder.scad
	@mkdir -p ./stls/.thumbnails/ 2>/dev/null || true

	$(OPENSCAD) -o $@ \
		-o ./stls/.thumbnails/$(basename $(notdir $@)).png \
		--render \
		-D 'SKADIS_BACKPLATE=true' \
		-D 'BUILD_PLATE_WIDTH=$(word 1,$(subst mm_, ,$*))' \
		-D 'NUMBER_OF_PLATES=$(word 2,$(subst _, ,$*))' \
		$<

stls/standing_%.stl: build_plate_holder.scad
	@mkdir -p ./stls/.thumbnails/ 2>/dev/null || true
	

	$(OPENSCAD) -o $@ \
		-o ./stls/.thumbnails/$(basename $(notdir $@)).png \
		--render \
		-D 'SKADIS_BACKPLATE=false' \
		-D 'BUILD_PLATE_WIDTH=$(word 1,$(subst mm_, ,$*))' \
		-D 'NUMBER_OF_PLATES=$(word 2,$(subst _, ,$*))' \
		$<