module mp_int

#include "sll_working_precision.h"
  use sll_m_constants
  use sll_m_boundary_condition_descriptors
  use sll_m_interpolators_2d_base
  use sll_m_cubic_spline_interpolator_2d
  use sll_m_cubic_splines
  use sll_m_poisson_2d_periodic
  use sll_m_poisson_2d_base, only: &
    sll_c_poisson_2d_base

  implicit none

contains

  subroutine interpolate_2d(N1, N2, data_in, &
       char_x1, char_x2, &
       data_exit, eta1_slopes, eta2_slopes)
    integer*4, intent(in) :: N1, N2
    real*8, intent(in), dimension(:, :) :: char_x1
    real*8, intent(in), dimension(:, :) :: char_x2
    real*8, intent(in), dimension(:, :) :: data_in
    real*8, dimension(2,N2) :: eta1_slopes
    real*8, dimension(2,N1) :: eta2_slopes
    real*8, intent(out), dimension(N1,N2) :: data_exit
    class(sll_c_interpolator_2d), pointer :: cs2d
    type(sll_t_cubic_spline_interpolator_2d), target    :: spline

    !-------------------------------------------------------
    !f2py integer*4, intent(in,hide)  :: N1, N2
    !f2py real*8, intent(in), dimension(N1, N2) :: data_in
    !--------------------------------------------------------

    call spline%init(N1,N2, &
         0.0_f64,1.0_f64,0.0_f64,1.0_f64,&
         sll_p_hermite, sll_p_hermite, &
         eta1_min_slopes=eta1_slopes(1, :), &
         eta1_max_slopes=eta1_slopes(2, :), &
         eta2_min_slopes=eta2_slopes(1, :), &
         eta2_max_slopes=eta2_slopes(2, :))

    cs2d =>  spline

    call cs2d % interpolate_array(N1, N2, data_in, char_x1, char_x2, data_exit)

  end subroutine interpolate_2d


  subroutine alt_interpolate_2d(N1, N2, data_in, &
       char_x1, char_x2, &
       data_out, eta1_slopes, eta2_slopes)
    integer*4, intent(in) :: N1, N2
    real*8, intent(in), dimension(:, :) :: char_x1
    real*8, intent(in), dimension(:, :) :: char_x2
    real*8, intent(in), dimension(:, :) :: data_in
    real*8, dimension(2,N2) :: eta1_slopes
    real*8, dimension(2,N1) :: eta2_slopes
    real*8, intent(out), dimension(N1,N2) :: data_out
    class(sll_c_interpolator_2d), pointer :: cs2d
    type(sll_t_cubic_spline_interpolator_2d), target    :: spline
    integer*4 :: i, j
    real*8    :: eta1
    real*8    :: eta2
    real*8, dimension((N1+2)*(N2+2)) :: coeffs

    !-------------------------------------------------------
    !f2py integer*4, intent(in,hide)  :: N1, N2
    !f2py real*8, intent(in), dimension(N1, N2) :: data_in
    !--------------------------------------------------------

    data_out(:,:) = 0._f64
    call spline%init(N1,N2, &
         0.0_f64,1.0_f64,0.0_f64,1.0_f64,&
         sll_p_hermite, sll_p_hermite, &
         eta1_min_slopes=eta1_slopes(1, :), &
         eta1_max_slopes=eta1_slopes(2, :), &
         eta2_min_slopes=eta2_slopes(1, :), &
         eta2_max_slopes=eta2_slopes(2, :))

    cs2d =>  spline

    call cs2d%compute_interpolants(data_in)
    coeffs(:) = 0.d+0
    call sll_s_get_coeff_cubic_spline_2d(spline%spline, coeffs)

    do j=1,N2
       do i=1,N1
          eta1 = char_x1(i,j)
          eta2 = char_x2(i,j)
          data_out(i,j) = cs2d%interpolate_from_interpolant_value(eta1,eta2)
          if ((abs(data_out(i,j)).le.0.000000000001d+0)&
               .and.(abs(data_out(i,j)).gt. 0d+0)) then
             print *, "i, j, res =", i, j, data_out(i,j)
             print *, "x1, x2 =", eta1, eta2
             print *, "coefs ", coeffs
             print *, "slopes1 =", eta1_slopes
             print *, "slopes2 =", eta2_slopes
             STOP
          else
             print *, "i, j, res =", i, j, data_out(i,j), &
                  abs(data_out(i,j)).le.0.000000000001d+0, &
                  abs(data_out(i,j)).gt.0.d+0
          end if
       end do
    end do

  end subroutine alt_interpolate_2d

  subroutine interpolate_value(NPTS1, NPTS2, &
       xi1, xi2, data, eta1_slopes, eta2_slopes, res)
    integer*4, intent(in) :: NPTS1, NPTS2
    real*8, dimension(2,NPTS1), optional :: eta1_slopes
    real*8, dimension(2,NPTS2), optional :: eta2_slopes
    real*8, intent(in), dimension(NPTS1,NPTS2) :: data
    real*8, intent(in)    :: xi1
    real*8, intent(in)    :: xi2
    real*8, intent(out)   :: res
    class(sll_c_interpolator_2d), pointer :: cs2d

    !-------------------------------------------------------
    !f2py integer*4, intent(in,hide)  :: NPTS1, NPTS2
    !f2py real*8, intent(in), dimension(2, NPTS2), optional :: eta1_slopes
    !f2py real*8, intent(in), dimension(2, NPTS1), optional :: eta2_slopes
    !--------------------------------------------------------

    if ((present(eta1_slopes)).and.(present(eta2_slopes))) then
       cs2d => sll_f_new_cubic_spline_interpolator_2d( &
            NPTS1, &
            NPTS2, &
            0.0_f64, &
            1.0_f64, &
            0.0_f64, &
            1.0_f64, &
            eta1_bc_type = sll_p_hermite, &
            eta2_bc_type = sll_p_hermite, &
            eta1_min_slopes=eta1_slopes(1, :), &
            eta1_max_slopes=eta1_slopes(2, :), &
            eta2_min_slopes=eta2_slopes(1, :), &
            eta2_max_slopes=eta2_slopes(2, :))
    else
       cs2d => sll_f_new_cubic_spline_interpolator_2d( &
            NPTS1, &
            NPTS2, &
            0.0_f64, &
            1.0_f64, &
            0.0_f64, &
            1.0_f64, &
            eta1_bc_type = sll_p_hermite, &
            eta2_bc_type = sll_p_hermite)
    endif

    call cs2d%compute_interpolants(data)

    res = cs2d % interpolate_from_interpolant_value(xi1,xi2)

  end subroutine interpolate_value

  subroutine poisson_solver_periodic(N1, N2, rho, phi)
    integer*4, intent(in) :: N1
    integer*4, intent(in) :: N2
    real*8,    intent(in),  dimension(:, :)   :: rho
    real*8,    intent(out), dimension(N1, N2) :: phi
    class(sll_c_poisson_2d_base), pointer     :: poisson
    type(sll_t_poisson_2d_periodic), target   :: poisson_tg


    poisson => sll_f_new_poisson_2d_periodic( &
         0.0_f64, &
         1.0_f64, &
         N1,   &
         0.0_f64, &
         1.0_f64, &
         N2)
    call poisson%compute_phi_from_rho(phi, rho)
  end subroutine poisson_solver_periodic

end module mp_int
