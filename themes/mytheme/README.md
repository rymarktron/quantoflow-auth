# Quantoflow Theme for Keycloak

A custom Keycloak theme featuring the Quantoflow logo and a modern, streamlined design.

## Theme Structure

```
mytheme/
├── theme.properties          # Root theme configuration
├── login/
│   ├── theme.properties      # Login theme configuration
│   ├── login.ftl             # Login page template
│   ├── waves.svg             # Decorative wave background
│   └── resources/
│       ├── css/
│       │   └── login.css     # Custom login page styles
│       └── img/
│           └── quantoflow-logo.png  # Quantoflow logo
└── README.md                 # This file
```

## Features

- **Custom Logo**: Uses the Quantoflow logo instead of the default Keycloak logo
- **Modern Styling**: Green gradient background with contemporary UI elements
- **Responsive Design**: Optimized for desktop and mobile devices
- **Customizable**: Easy to modify colors, fonts, and layout

## Installation & Usage

### Step 1: Enable the Theme in Keycloak Admin Console

1. Start your Keycloak server
2. Navigate to the Keycloak Admin Console
3. Go to **Realm Settings** → **Themes**
4. Set the **Login Theme** to `mytheme`
5. Click **Save**

### Step 2: Test the Theme

Navigate to your Keycloak login page (usually `http://localhost:8080/auth/realms/{realm}/protocol/openid-connect/auth`)

You should see the Quantoflow logo displayed at the top of the login page.

## Customization

### Change the Logo

Replace `/resources/img/quantoflow-logo.png` with your own image file. Keep the filename the same or update the reference in `login.ftl`.

### Modify Colors

Edit `/resources/css/login.css` and update the color values:
- Primary green: `#4a9d6f`
- Dark green: `#2d7a52`
- Background gradient colors

### Customize Text

Edit `/login/login.ftl` to modify text, layout, or add additional form fields.

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

## References

- [Keycloak Theme Documentation](https://www.keycloak.org/docs/latest/server_development/#_themes)
- [FreeMarker Template Guide](https://freemarker.apache.org/)
