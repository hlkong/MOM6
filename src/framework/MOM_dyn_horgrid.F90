module MOM_dyn_horgrid

! This file is part of MOM6. See LICENSE.md for the license.

use MOM_hor_index, only : hor_index_type
use MOM_domains, only : MOM_domain_type
use MOM_error_handler, only : MOM_error, MOM_mesg, FATAL, WARNING

implicit none ; private

public create_dyn_horgrid, destroy_dyn_horgrid, set_derived_dyn_horgrid

!> Describes the horizontal ocean grid with only dynamic memory arrays
type, public :: dyn_horgrid_type
  type(MOM_domain_type), pointer :: Domain => NULL() !< Ocean model domain
  type(MOM_domain_type), pointer :: Domain_aux => NULL() !< A non-symmetric auxiliary domain type.
  type(hor_index_type) :: HI !< Horizontal index ranges

  integer :: isc !< The start i-index of cell centers within the computational domain
  integer :: iec !< The end i-index of cell centers within the computational domain
  integer :: jsc !< The start j-index of cell centers within the computational domain
  integer :: jec !< The end j-index of cell centers within the computational domain

  integer :: isd !< The start i-index of cell centers within the data domain
  integer :: ied !< The end i-index of cell centers within the data domain
  integer :: jsd !< The start j-index of cell centers within the data domain
  integer :: jed !< The end j-index of cell centers within the data domain

  integer :: isg !< The start i-index of cell centers within the global domain
  integer :: ieg !< The end i-index of cell centers within the global domain
  integer :: jsg !< The start j-index of cell centers within the global domain
  integer :: jeg !< The end j-index of cell centers within the global domain

  integer :: IscB !< The start i-index of cell vertices within the computational domain
  integer :: IecB !< The end i-index of cell vertices within the computational domain
  integer :: JscB !< The start j-index of cell vertices within the computational domain
  integer :: JecB !< The end j-index of cell vertices within the computational domain

  integer :: IsdB !< The start i-index of cell vertices within the data domain
  integer :: IedB !< The end i-index of cell vertices within the data domain
  integer :: JsdB !< The start j-index of cell vertices within the data domain
  integer :: JedB !< The end j-index of cell vertices within the data domain

  integer :: IsgB !< The start i-index of cell vertices within the global domain
  integer :: IegB !< The end i-index of cell vertices within the global domain
  integer :: JsgB !< The start j-index of cell vertices within the global domain
  integer :: JegB !< The end j-index of cell vertices within the global domain

  integer :: isd_global !< The value of isd in the global index space (decompoistion invariant).
  integer :: jsd_global !< The value of isd in the global index space (decompoistion invariant).
  integer :: idg_offset !< The offset between the corresponding global and local i-indices.
  integer :: jdg_offset !< The offset between the corresponding global and local j-indices.
  logical :: symmetric  !< True if symmetric memory is used.

  logical :: nonblocking_updates  !< If true, non-blocking halo updates are
                                  !! allowed.  The default is .false. (for now).
  integer :: first_direction !< An integer that indicates which direction is to be updated first in
                             !! directionally split parts of the calculation.  This can be altered
                             !! during the course of the run via calls to set_first_direction.

  real, allocatable, dimension(:,:) :: &
    mask2dT, &   !< 0 for land points and 1 for ocean points on the h-grid. Nd.
    geoLatT, &   !< The geographic latitude at q points in degrees of latitude or m.
    geoLonT, &   !< The geographic longitude at q points in degrees of longitude or m.
    dxT, &       !< dxT is delta x at h points, in m.
    IdxT, &      !< 1/dxT in m-1.
    dyT, &       !< dyT is delta y at h points, in m, and IdyT is 1/dyT in m-1.
    IdyT, &      !< dyT is delta y at h points, in m, and IdyT is 1/dyT in m-1.
    areaT, &     !< The area of an h-cell, in m2.
    IareaT       !< 1/areaT, in m-2.
  real, allocatable, dimension(:,:) :: sin_rot
                 !< The sine of the angular rotation between the local model grid's northward
                 !! and the true northward directions.
  real, allocatable, dimension(:,:) :: cos_rot
                 !< The cosine of the angular rotation between the local model grid's northward
                 !! and the true northward directions.

  real, allocatable, dimension(:,:) :: &
    mask2dCu, &  !< 0 for boundary points and 1 for ocean points on the u grid.  Nondim.
    geoLatCu, &  !< The geographic latitude at u points in degrees of latitude or m.
    geoLonCu, &  !< The geographic longitude at u points in degrees of longitude or m.
    dxCu, &      !< dxCu is delta x at u points, in m.
    IdxCu, &     !< 1/dxCu in m-1.
    dyCu, &      !< dyCu is delta y at u points, in m.
    IdyCu, &     !< 1/dyCu in m-1.
    dy_Cu, &     !< The unblocked lengths of the u-faces of the h-cell in m.
    IareaCu, &   !< The masked inverse areas of u-grid cells in m2.
    areaCu       !< The areas of the u-grid cells in m2.

  real, allocatable, dimension(:,:) :: &
    mask2dCv, &  !< 0 for boundary points and 1 for ocean points on the v grid.  Nondim.
    geoLatCv, &  !< The geographic latitude at v points in degrees of latitude or m.
    geoLonCv, &  !< The geographic longitude at v points in degrees of longitude or m.
    dxCv, &      !< dxCv is delta x at v points, in m.
    IdxCv, &     !< 1/dxCv in m-1.
    dyCv, &      !< dyCv is delta y at v points, in m.
    IdyCv, &     !< 1/dyCv in m-1.
    dx_Cv, &     !< The unblocked lengths of the v-faces of the h-cell in m.
    IareaCv, &   !< The masked inverse areas of v-grid cells in m2.
    areaCv       !< The areas of the v-grid cells in m2.

  real, allocatable, dimension(:,:) :: &
    mask2dBu, &  !< 0 for boundary points and 1 for ocean points on the q grid.  Nondim.
    geoLatBu, &  !< The geographic latitude at q points in degrees of latitude or m.
    geoLonBu, &  !< The geographic longitude at q points in degrees of longitude or m.
    dxBu, &      !< dxBu is delta x at q points, in m.
    IdxBu, &     !< 1/dxBu in m-1.
    dyBu, &      !< dyBu is delta y at q points, in m.
    IdyBu, &     !< 1/dyBu in m-1.
    areaBu, &    !< areaBu is the area of a q-cell, in m2
    IareaBu      !< IareaBu = 1/areaBu in m-2.

  real, pointer, dimension(:) :: gridLatT => NULL()
        !< The latitude of T points for the purpose of labeling the output axes.
        !! On many grids this is the same as geoLatT.
  real, pointer, dimension(:) :: gridLatB => NULL()
        !< The latitude of B points for the purpose of labeling the output axes.
        !! On many grids this is the same as geoLatBu.
  real, pointer, dimension(:) :: gridLonT => NULL()
        !< The longitude of T points for the purpose of labeling the output axes.
        !! On many grids this is the same as geoLonT.
  real, pointer, dimension(:) :: gridLonB => NULL()
        !< The longitude of B points for the purpose of labeling the output axes.
        !! On many grids this is the same as geoLonBu.
  character(len=40) :: &
    x_axis_units, &     !< The units that are used in labeling the x coordinate axes.
    y_axis_units        !< The units that are used in labeling the y coordinate axes.
    ! Except on a Cartesian grid, these are usually  some variant of "degrees".

  real, allocatable, dimension(:,:) :: &
    bathyT        !< Ocean bottom depth at tracer points, in m.

  logical :: bathymetry_at_vel  !< If true, there are separate values for the
                  !! basin depths at velocity points.  Otherwise the effects of
                  !! of topography are entirely determined from thickness points.
  real, allocatable, dimension(:,:) :: &
    Dblock_u, &   !< Topographic depths at u-points at which the flow is blocked, in m.
    Dopen_u       !< Topographic depths at u-points at which the flow is open at width dy_Cu, in m.
  real, allocatable, dimension(:,:) :: &
    Dblock_v, &   !< Topographic depths at v-points at which the flow is blocked, in m.
    Dopen_v       !< Topographic depths at v-points at which the flow is open at width dx_Cv, in m.
  real, allocatable, dimension(:,:) :: &
    CoriolisBu    !< The Coriolis parameter at corner points, in s-1.
  real, allocatable, dimension(:,:) :: &
    df_dx, &      !< Derivative d/dx f (Coriolis parameter) at h-points, in s-1 m-1.
    df_dy         !< Derivative d/dy f (Coriolis parameter) at h-points, in s-1 m-1.

  ! These variables are global sums that are useful for 1-d diagnostics
  real :: areaT_global  !< Global sum of h-cell area in m2
  real :: IareaT_global !< Global sum of inverse h-cell area (1/areaT_global) in m2

  ! These parameters are run-time parameters that are used during some
  ! initialization routines (but not all)
  real :: south_lat     !< The latitude (or y-coordinate) of the first v-line
  real :: west_lon      !< The longitude (or x-coordinate) of the first u-line
  real :: len_lat = 0.  !< The latitudinal (or y-coord) extent of physical domain
  real :: len_lon = 0.  !< The longitudinal (or x-coord) extent of physical domain
  real :: Rad_Earth = 6.378e6 !< The radius of the planet in meters.
  real :: max_depth     !< The maximum depth of the ocean in meters.
end type dyn_horgrid_type

contains

!---------------------------------------------------------------------
!> Allocate memory used by the dyn_horgrid_type and related structures.
subroutine create_dyn_horgrid(G, HI, bathymetry_at_vel)
  type(dyn_horgrid_type), pointer    :: G  !< A pointer to the dynamic horizontal grid type
  type(hor_index_type),   intent(in) :: HI !< A hor_index_type for array extents
  logical,        optional, intent(in) :: bathymetry_at_vel !< If true, there are
                             !! separate values for the basin depths at velocity
                             !! points.  Otherwise the effects of topography are
                             !! entirely determined from thickness points.
  integer :: isd, ied, jsd, jed, IsdB, IedB, JsdB, JedB, isg, ieg, jsg, jeg

  ! This subroutine allocates the lateral elements of the dyn_horgrid_type that
  ! are always used and zeros them out.

  if (associated(G)) then
    call MOM_error(WARNING, "create_dyn_horgrid called with an associated horgrid_type.")
  else
    allocate(G)
  endif

  G%HI = HI

  G%isc = HI%isc ; G%iec = HI%iec ; G%jsc = HI%jsc ; G%jec = HI%jec
  G%isd = HI%isd ; G%ied = HI%ied ; G%jsd = HI%jsd ; G%jed = HI%jed
  G%isg = HI%isg ; G%ieg = HI%ieg ; G%jsg = HI%jsg ; G%jeg = HI%jeg

  G%IscB = HI%IscB ; G%IecB = HI%IecB ; G%JscB = HI%JscB ; G%JecB = HI%JecB
  G%IsdB = HI%IsdB ; G%IedB = HI%IedB ; G%JsdB = HI%JsdB ; G%JedB = HI%JedB
  G%IsgB = HI%IsgB ; G%IegB = HI%IegB ; G%JsgB = HI%JsgB ; G%JegB = HI%JegB

  G%idg_offset = HI%idg_offset ; G%jdg_offset = HI%jdg_offset
  G%isd_global = G%isd + HI%idg_offset ; G%jsd_global = G%jsd + HI%jdg_offset
  G%symmetric = HI%symmetric

  G%bathymetry_at_vel = .false.
  if (present(bathymetry_at_vel)) G%bathymetry_at_vel = bathymetry_at_vel

  isd = G%isd ; ied = G%ied ; jsd = G%jsd ; jed = G%jed
  IsdB = G%IsdB ; IedB = G%IedB ; JsdB = G%JsdB ; JedB = G%JedB
  isg = G%isg ; ieg = G%ieg ; jsg = G%jsg ; jeg = G%jeg

  allocate(G%dxT(isd:ied,jsd:jed))       ; G%dxT(:,:) = 0.0
  allocate(G%dxCu(IsdB:IedB,jsd:jed))    ; G%dxCu(:,:) = 0.0
  allocate(G%dxCv(isd:ied,JsdB:JedB))    ; G%dxCv(:,:) = 0.0
  allocate(G%dxBu(IsdB:IedB,JsdB:JedB))  ; G%dxBu(:,:) = 0.0
  allocate(G%IdxT(isd:ied,jsd:jed))      ; G%IdxT(:,:) = 0.0
  allocate(G%IdxCu(IsdB:IedB,jsd:jed))   ; G%IdxCu(:,:) = 0.0
  allocate(G%IdxCv(isd:ied,JsdB:JedB))   ; G%IdxCv(:,:) = 0.0
  allocate(G%IdxBu(IsdB:IedB,JsdB:JedB)) ; G%IdxBu(:,:) = 0.0

  allocate(G%dyT(isd:ied,jsd:jed))       ; G%dyT(:,:) = 0.0
  allocate(G%dyCu(IsdB:IedB,jsd:jed))    ; G%dyCu(:,:) = 0.0
  allocate(G%dyCv(isd:ied,JsdB:JedB))    ; G%dyCv(:,:) = 0.0
  allocate(G%dyBu(IsdB:IedB,JsdB:JedB))  ; G%dyBu(:,:) = 0.0
  allocate(G%IdyT(isd:ied,jsd:jed))      ; G%IdyT(:,:) = 0.0
  allocate(G%IdyCu(IsdB:IedB,jsd:jed))   ; G%IdyCu(:,:) = 0.0
  allocate(G%IdyCv(isd:ied,JsdB:JedB))   ; G%IdyCv(:,:) = 0.0
  allocate(G%IdyBu(IsdB:IedB,JsdB:JedB)) ; G%IdyBu(:,:) = 0.0

  allocate(G%areaT(isd:ied,jsd:jed))       ; G%areaT(:,:) = 0.0
  allocate(G%IareaT(isd:ied,jsd:jed))      ; G%IareaT(:,:) = 0.0
  allocate(G%areaBu(IsdB:IedB,JsdB:JedB))  ; G%areaBu(:,:) = 0.0
  allocate(G%IareaBu(IsdB:IedB,JsdB:JedB)) ; G%IareaBu(:,:) = 0.0

  allocate(G%mask2dT(isd:ied,jsd:jed))      ; G%mask2dT(:,:) = 0.0
  allocate(G%mask2dCu(IsdB:IedB,jsd:jed))   ; G%mask2dCu(:,:) = 0.0
  allocate(G%mask2dCv(isd:ied,JsdB:JedB))   ; G%mask2dCv(:,:) = 0.0
  allocate(G%mask2dBu(IsdB:IedB,JsdB:JedB)) ; G%mask2dBu(:,:) = 0.0
  allocate(G%geoLatT(isd:ied,jsd:jed))      ; G%geoLatT(:,:) = 0.0
  allocate(G%geoLatCu(IsdB:IedB,jsd:jed))   ; G%geoLatCu(:,:) = 0.0
  allocate(G%geoLatCv(isd:ied,JsdB:JedB))   ; G%geoLatCv(:,:) = 0.0
  allocate(G%geoLatBu(IsdB:IedB,JsdB:JedB)) ; G%geoLatBu(:,:) = 0.0
  allocate(G%geoLonT(isd:ied,jsd:jed))      ; G%geoLonT(:,:) = 0.0
  allocate(G%geoLonCu(IsdB:IedB,jsd:jed))   ; G%geoLonCu(:,:) = 0.0
  allocate(G%geoLonCv(isd:ied,JsdB:JedB))   ; G%geoLonCv(:,:) = 0.0
  allocate(G%geoLonBu(IsdB:IedB,JsdB:JedB)) ; G%geoLonBu(:,:) = 0.0

  allocate(G%dx_Cv(isd:ied,JsdB:JedB))     ; G%dx_Cv(:,:) = 0.0
  allocate(G%dy_Cu(IsdB:IedB,jsd:jed))     ; G%dy_Cu(:,:) = 0.0

  allocate(G%areaCu(IsdB:IedB,jsd:jed))  ; G%areaCu(:,:) = 0.0
  allocate(G%areaCv(isd:ied,JsdB:JedB))  ; G%areaCv(:,:) = 0.0
  allocate(G%IareaCu(IsdB:IedB,jsd:jed)) ; G%IareaCu(:,:) = 0.0
  allocate(G%IareaCv(isd:ied,JsdB:JedB)) ; G%IareaCv(:,:) = 0.0

  allocate(G%bathyT(isd:ied, jsd:jed)) ; G%bathyT(:,:) = 0.0
  allocate(G%CoriolisBu(IsdB:IedB, JsdB:JedB)) ; G%CoriolisBu(:,:) = 0.0
  allocate(G%dF_dx(isd:ied, jsd:jed)) ; G%dF_dx(:,:) = 0.0
  allocate(G%dF_dy(isd:ied, jsd:jed)) ; G%dF_dy(:,:) = 0.0

  allocate(G%sin_rot(isd:ied,jsd:jed)) ; G%sin_rot(:,:) = 0.0
  allocate(G%cos_rot(isd:ied,jsd:jed)) ; G%cos_rot(:,:) = 1.0

  if (G%bathymetry_at_vel) then
    allocate(G%Dblock_u(IsdB:IedB, jsd:jed)) ; G%Dblock_u(:,:) = 0.0
    allocate(G%Dopen_u(IsdB:IedB, jsd:jed))  ; G%Dopen_u(:,:) = 0.0
    allocate(G%Dblock_v(isd:ied, JsdB:JedB)) ; G%Dblock_v(:,:) = 0.0
    allocate(G%Dopen_v(isd:ied, JsdB:JedB))  ; G%Dopen_v(:,:) = 0.0
  endif

  ! gridLonB and gridLatB are used as edge values in some cases, so they
  ! always need to use symmetric memory allcoations.
  allocate(G%gridLonT(isg:ieg))   ; G%gridLonT(:) = 0.0
  allocate(G%gridLonB(isg-1:ieg)) ; G%gridLonB(:) = 0.0
  allocate(G%gridLatT(jsg:jeg))   ; G%gridLatT(:) = 0.0
  allocate(G%gridLatB(jsg-1:jeg)) ; G%gridLatB(:) = 0.0

end subroutine create_dyn_horgrid

!> set_derived_dyn_horgrid calculates metric terms that are derived from other metrics.
subroutine set_derived_dyn_horgrid(G)
  type(dyn_horgrid_type), intent(inout) :: G !< The dynamic horizontal grid type
!    Various inverse grid spacings and derived areas are calculated within this
!  subroutine.
  integer :: i, j, isd, ied, jsd, jed
  integer :: IsdB, IedB, JsdB, JedB

  isd = G%isd ; ied = G%ied ; jsd = G%jsd ; jed = G%jed
  IsdB = G%IsdB ; IedB = G%IedB ; JsdB = G%JsdB ; JedB = G%JedB

  do j=jsd,jed ; do i=isd,ied
    if (G%dxT(i,j) < 0.0) G%dxT(i,j) = 0.0
    if (G%dyT(i,j) < 0.0) G%dyT(i,j) = 0.0
    G%IdxT(i,j) = Adcroft_reciprocal(G%dxT(i,j))
    G%IdyT(i,j) = Adcroft_reciprocal(G%dyT(i,j))
    G%IareaT(i,j) = Adcroft_reciprocal(G%areaT(i,j))
  enddo ; enddo

  do j=jsd,jed ; do I=IsdB,IedB
    if (G%dxCu(I,j) < 0.0) G%dxCu(I,j) = 0.0
    if (G%dyCu(I,j) < 0.0) G%dyCu(I,j) = 0.0
    G%IdxCu(I,j) = Adcroft_reciprocal(G%dxCu(I,j))
    G%IdyCu(I,j) = Adcroft_reciprocal(G%dyCu(I,j))
  enddo ; enddo

  do J=JsdB,JedB ; do i=isd,ied
    if (G%dxCv(i,J) < 0.0) G%dxCv(i,J) = 0.0
    if (G%dyCv(i,J) < 0.0) G%dyCv(i,J) = 0.0
    G%IdxCv(i,J) = Adcroft_reciprocal(G%dxCv(i,J))
    G%IdyCv(i,J) = Adcroft_reciprocal(G%dyCv(i,J))
  enddo ; enddo

  do J=JsdB,JedB ; do I=IsdB,IedB
    if (G%dxBu(I,J) < 0.0) G%dxBu(I,J) = 0.0
    if (G%dyBu(I,J) < 0.0) G%dyBu(I,J) = 0.0

    G%IdxBu(I,J) = Adcroft_reciprocal(G%dxBu(I,J))
    G%IdyBu(I,J) = Adcroft_reciprocal(G%dyBu(I,J))
    ! areaBu has usually been set to a positive area elsewhere.
    if (G%areaBu(I,J) <= 0.0) G%areaBu(I,J) = G%dxBu(I,J) * G%dyBu(I,J)
    G%IareaBu(I,J) =  Adcroft_reciprocal(G%areaBu(I,J))
  enddo ; enddo

end subroutine set_derived_dyn_horgrid

!> Adcroft_reciprocal(x) = 1/x for |x|>0 or 0 for x=0.
function Adcroft_reciprocal(val) result(I_val)
  real, intent(in) :: val  !< The value being inverted.
  real :: I_val            !< The Adcroft reciprocal of val.

  I_val = 0.0 ; if (val /= 0.0) I_val = 1.0/val
end function Adcroft_reciprocal

!---------------------------------------------------------------------
!> Release memory used by the dyn_horgrid_type and related structures.
subroutine destroy_dyn_horgrid(G)
  type(dyn_horgrid_type), pointer :: G !< The dynamic horizontal grid type

  if (.not.associated(G)) then
    call MOM_error(FATAL, "destroy_dyn_horgrid called with an unassociated horgrid_type.")
  endif

  deallocate(G%dxT)  ; deallocate(G%dxCu)  ; deallocate(G%dxCv)  ; deallocate(G%dxBu)
  deallocate(G%IdxT) ; deallocate(G%IdxCu) ; deallocate(G%IdxCv) ; deallocate(G%IdxBu)

  deallocate(G%dyT)  ; deallocate(G%dyCu)  ; deallocate(G%dyCv)  ; deallocate(G%dyBu)
  deallocate(G%IdyT) ; deallocate(G%IdyCu) ; deallocate(G%IdyCv) ; deallocate(G%IdyBu)

  deallocate(G%areaT)  ; deallocate(G%IareaT)
  deallocate(G%areaBu) ; deallocate(G%IareaBu)
  deallocate(G%areaCu) ; deallocate(G%IareaCu)
  deallocate(G%areaCv)  ; deallocate(G%IareaCv)

  deallocate(G%mask2dT)  ; deallocate(G%mask2dCu)
  deallocate(G%mask2dCv) ; deallocate(G%mask2dBu)

  deallocate(G%geoLatT)  ; deallocate(G%geoLatCu)
  deallocate(G%geoLatCv) ; deallocate(G%geoLatBu)
  deallocate(G%geoLonT)  ; deallocate(G%geoLonCu)
  deallocate(G%geoLonCv) ; deallocate(G%geoLonBu)

  deallocate(G%dx_Cv) ; deallocate(G%dy_Cu)

  deallocate(G%bathyT)  ; deallocate(G%CoriolisBu)
  deallocate(G%dF_dx)  ; deallocate(G%dF_dy)
  deallocate(G%sin_rot) ; deallocate(G%cos_rot)

  if (allocated(G%Dblock_u)) deallocate(G%Dblock_u)
  if (allocated(G%Dopen_u)) deallocate(G%Dopen_u)
  if (allocated(G%Dblock_v)) deallocate(G%Dblock_v)
  if (allocated(G%Dopen_v)) deallocate(G%Dopen_v)

  deallocate(G%gridLonT) ; deallocate(G%gridLatT)
  deallocate(G%gridLonB) ; deallocate(G%gridLatB)

  deallocate(G%Domain%mpp_domain)
  deallocate(G%Domain)

  deallocate(G)

end subroutine destroy_dyn_horgrid

end module MOM_dyn_horgrid
