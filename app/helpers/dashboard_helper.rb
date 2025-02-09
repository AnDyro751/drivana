module DashboardHelper
  def navigation_menu_items
    items = [
      {
        title: "Dashboard",
        path: dashboard_path,
        icon: "home",
        active: controller_name == "dashboard"
      },
      {
        title: "Mis Reservaciones",
        path: dashboard_bookings_path,
        icon: "calendar",
        active: controller_name == "bookings"
      }
    ]

    # Solo hosts ven la sección de carros
    if current_user.role_host?
      items << {
        title: "Mis Vehículos",
        path: dashboard_cars_path,
        icon: "car",
        active: controller_name == "cars"
      }
    end

    items
  end

  def render_icon(name)
    case name
    when "home"
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
        </svg>
      SVG
    when "car"
      <<-SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z" />
          <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7h-3v7h3V7z" />
        </svg>
      SVG
    when "calendar"
      <<-SVG.html_safe
      <svg version="1.1" id="calendars" class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" x="0" y="0" viewBox="0 0 128 128" style="enable-background:new 0 0 128 128" xml:space="preserve"><style>.st0{display:none}.st1{display:inline}.st2{fill:#232323}.st3{display:inline;fill:#fff}.st4{font-family:&apos;Helvetica-Bold&apos;}.st6{display:inline;fill-rule:evenodd;clip-rule:evenodd}.st10,.st6,.st7{fill:#232323}.st7{display:inline}.st10{fill-rule:evenodd;clip-rule:evenodd}</style><g id="calendar_:_5"><path id="border_4_" class="st10" d="M13.8.9C8.4.9 4.1 6.8 4.1 12.1V116c0 5.3 4.4 11.2 9.7 11.2h87.4L124 100V12.1c0-5.3-4.4-11.2-9.7-11.2v6.4s3.2 2.8 3.2 6.2v83.3H94.8v24H15.2c-3.5 0-4.7-1.2-4.7-4.6V13.4c0-3.4 3.2-6.2 3.2-6.2V.9z"/><path class="st2" d="M26.7 90.4h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6H30v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0H51v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0H64v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.2 0H77v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.2 0h1.6v-1.6h-1.6v1.6zm3.3 0h1.6v-1.6h-1.6v1.6zm3.2-1.6v1.6h1.6v-1.6H98z" id="line"/><path id="top_18_" class="st10" d="M12.2.9h103.7c3.8 0 8.1 5.9 8.1 9.6v27.2H4.1V10.5C4.1 6.7 8.3.9 12.2.9z"/><text transform="matrix(1.0137 0 0 1 42.935 28.035)" class="st4" style="font-size:22.3771px;fill:#fff">Jun</text><text transform="matrix(1.0137 0 0 1 28.354 85.574)" class="st2 st4" style="font-size:57.5413px">10</text><text transform="matrix(1.0137 0 0 1 42.935 111.148)" class="st2 st4" style="font-size:19.1804px">Wed</text></g></svg>
      SVG
    end
  end

  def user_has_active_booking?(car, user = current_user)
    user.bookings
               .where(car: car, status: [ :pending, :confirmed ])
               .exists?
  end

  def get_active_booking(car, user = current_user)
    user.bookings
               .where(car: car, status: [ :pending, :confirmed ])
               .first
  end
end
