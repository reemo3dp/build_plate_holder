OPENSCAD ?= openscad

.PHONY: all clean

SIZES := 120mm 180mm 235mm 254mm 256mm 305mm 355mm
NUMBERS := 2 3 4 5
STYLE := staircase level
LOGO := voron r3d

all: $(foreach size,$(SIZES),\
		$(foreach number,$(NUMBERS),\
			$(foreach style,$(STYLE),\
				$(foreach logo,$(LOGO),\
					stls/skadis_$(size)_$(style)_$(logo)_$(number).stl)))) \
	 $(foreach size,$(SIZES),\
	 	$(foreach number,$(NUMBERS),\
			$(foreach style,$(STYLE),\
				$(foreach logo,$(LOGO),\
					stls/standing_$(size)_$(style)_$(logo)_$(number).stl))))
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
		-D 'STAIRCASE=$(if $(filter staircase,$(word 2,$(subst _, ,$*))),true,false)' \
		-D 'LOGO="$(word 3,$(subst _, ,$*))"' \
		-D 'NUMBER_OF_PLATES=$(word 4,$(subst _, ,$*))' \
		$<

stls/standing_%.stl: build_plate_holder.scad
	@mkdir -p ./stls/.thumbnails/ 2>/dev/null || true
	

	$(OPENSCAD) -o $@ \
		-o ./stls/.thumbnails/$(basename $(notdir $@)).png \
		--render \
		-D 'SKADIS_BACKPLATE=false' \
		-D 'BUILD_PLATE_WIDTH=$(word 1,$(subst mm_, ,$*))' \
		-D 'STAIRCASE=$(if $(filter staircase,$(word 2,$(subst _, ,$*))),true,false)' \
		-D 'LOGO="$(word 3,$(subst _, ,$*))"' \
		-D 'NUMBER_OF_PLATES=$(word 4,$(subst _, ,$*))' \
		$<