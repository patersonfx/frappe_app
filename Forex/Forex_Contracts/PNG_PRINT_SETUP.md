# PNG-Based Contract Note Printing

## Overview
This feature allows printing contract notes on a PNG template and converting the result to PDF. The implementation overlays contract data on a blank contract note PNG template using Python imaging libraries.

## Installation

### Required Dependencies
```bash
# Activate the bench environment
source env/bin/activate

# Install required Python packages
pip install Pillow img2pdf
```

These packages are now installed and ready to use.

## Usage

### From List View
1. Navigate to the Forex Contracts list
2. Select one or more contracts by checking the checkboxes
3. Click the **"Print on PNG"** button that appears
4. Confirm the action in the dialog
5. The system will:
   - Generate a PDF with contract data overlaid on the PNG template
   - Automatically download the PDF
   - Mark the contracts as printed

### PNG Template Location
The blank contract note PNG template must be located at:
```
sites/erp.forex/private/files/Blank-Contract-Note.png
```

## Text Position and Font Size Adjustment

The current implementation uses predefined pixel coordinates to position text on the PNG template and allows you to control the font size for each element independently.

### Available Font Sizes

The implementation provides 5 different font sizes:
- **font_large**: 14 pixels - For prominent text
- **font_regular**: 12 pixels - For normal text (default)
- **font_medium**: 11 pixels - For slightly smaller text
- **font_small**: 10 pixels - For secondary information
- **font_tiny**: 8 pixels - For very small text

### How to Adjust Positions and Font Sizes

Edit the file: `forex/forex/doctype/forex_contracts/forex_contracts.py`

Look for the `_create_contract_image_on_png` function and find the `text_config` dictionary (around line 975):

```python
# ============================================================================
# TEXT CONFIGURATION - Adjust positions and font sizes here
# ============================================================================
# Available font sizes: font_large (14), font_regular (12), font_medium (11),
#                      font_small (10), font_tiny (8)
# Position format: (x, y) where x=horizontal pixels, y=vertical pixels
# ============================================================================

text_config = {
    'time': {'pos': (700, 58), 'font': font_regular},
    'number': {'pos': (700, 105), 'font': font_regular},
    'date': {'pos': (700, 153), 'font': font_regular},
    'seller_name': {'pos': (150, 195), 'font': font_regular},
    'seller_agent': {'pos': (150, 215), 'font': font_small},
    'buyer_name': {'pos': (150, 260), 'font': font_regular},
    'buyer_agent': {'pos': (150, 280), 'font': font_small},
    'amount': {'pos': (24, 342), 'font': font_regular},
    'currency': {'pos': (224, 342), 'font': font_regular},
    'usance': {'pos': (336, 395), 'font': font_small},
    'against': {'pos': (336, 415), 'font': font_small},
    'payable': {'pos': (336, 433), 'font': font_small},
    'rate': {'pos': (428, 342), 'font': font_regular},
    'delivery': {'pos': (562, 342), 'font': font_regular},
    'fund_type': {'pos': (562, 420), 'font': font_small},
}
```

Each configuration contains:
- **pos**: A tuple of `(x, y)` coordinates in pixels
  - `x`: horizontal position (0 = left edge)
  - `y`: vertical position (0 = top edge)
- **font**: The font object to use for that element

### Examples of Adjustments

**To change the font size of contract number to large:**
```python
'number': {'pos': (700, 105), 'font': font_large},
```

**To move the time field and make it smaller:**
```python
'time': {'pos': (720, 60), 'font': font_small},
```

**To adjust seller name position and use medium font:**
```python
'seller_name': {'pos': (160, 200), 'font': font_medium},
```

### Custom Font Sizes

If you need a font size not available in the predefined options, you can create a new font object in the font loading section (around line 924):

```python
# Add your custom font size
font_custom = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 15)
```

Then use it in the configuration:
```python
'amount': {'pos': (24, 342), 'font': font_custom},
```

### Testing Position Changes

To find the correct positions for your template:
1. Open your PNG template in an image editor (GIMP, Photoshop, etc.)
2. Use the ruler/coordinate tool to find the pixel coordinates where text should appear
3. Update the coordinates in the Python code
4. Test with a single contract
5. Iterate until positions are correct

### Visual Adjustment Helper

You can temporarily add guide lines to see where text is being placed:

```python
# Add this after loading the image in _create_contract_image_on_png
draw.rectangle([(650, 64), (750, 80)], outline='red')  # Shows TIME field area
```

## Contract Layout

Each contract generates **TWO separate pages**:
- **Page 1**: First copy (Near Leg) - Original seller and buyer
- **Page 2**: Second copy (Far Leg) - **Seller and buyer are swapped**

Both copies use the same PNG template and identical text positions. Each copy is printed on a fresh PNG template.

### Important: Seller/Buyer Swap in Far Leg
In the second copy (Far Leg):
- The **seller** from the first copy becomes the **buyer**
- The **buyer** from the first copy becomes the **seller**
- The **seller_agent** from the first copy becomes the **buyer_agent**
- The **buyer_agent** from the first copy becomes the **seller_agent**

This swap reflects the counter-party nature of forex contracts where each party has an opposite position.

### Example:
**Near Leg (Page 1):**
- Seller: Bank A
- Seller Agent: CCIL Settlement
- Buyer: Bank B
- Buyer Agent: RTGS

**Far Leg (Page 2):**
- Seller: Bank B (was buyer in Near Leg)
- Seller Agent: RTGS (was buyer agent in Near Leg)
- Buyer: Bank A (was seller in Near Leg)
- Buyer Agent: CCIL Settlement (was seller agent in Near Leg)

## Data Fields Populated

The following fields are automatically populated on the contract note:
- Contract Time (HH:MM:SS format)
- Contract Number
- Contract Date (DD/MM/YYYY format)
- Seller Bank Name
- Buyer Bank Name
- Seller Agent (CCIL Settlement/RTGS)
- Buyer Agent (CCIL Settlement/RTGS)
- Amount (USD with comma separators)
- Currency (USD)
- Exchange Rate (4 decimal places)
- Delivery Date (DD/MM/YYYY format)
- Payment Type (T.T)
- Settlement Currency (INR)
- Fund Location (Mumbai)

## Files Modified

1. **forex_contracts.py**: Backend Python code for PDF generation
   - `bulk_print_contracts_on_png()`: Main function
   - `_get_png_template_path()`: Locates PNG template
   - `_create_contract_image_on_png()`: Overlays data on PNG
   - `_convert_images_to_pdf()`: Converts images to PDF
   - `_cleanup_temp_files()`: Removes temporary files

2. **forex_contracts_list.js**: Frontend JavaScript for UI button
   - Added "Print on PNG" button
   - Added button visibility management
   - Added server method call and error handling

## Troubleshooting

### Error: "PNG template not found"
- Verify the PNG file exists at: `sites/erp.forex/private/files/Blank-Contract-Note.png`
- Check file permissions (should be readable by the Frappe user)

### Error: "Required libraries not found"
- Run: `pip install Pillow img2pdf` in the bench environment
- Restart bench after installation

### Text appears in wrong positions
- Adjust coordinates in `positions_top` dictionary
- Remember that the second copy is automatically offset by 560 pixels vertically
- Use an image editor to find exact pixel coordinates

### PDF is blank or missing text
- Check if fonts are available at `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf`
- The code has a fallback to default fonts if DejaVu is not available
- Verify the PNG template is not corrupted

## Differences from Pre-Printed Form Method

| Feature | Pre-Printed Form | PNG Template |
|---------|-----------------|--------------|
| Button | "Print Contracts" | "Print on PNG" |
| Method | `bulk_print_contracts` | `bulk_print_contracts_on_png` |
| Technology | ReportLab PDF | PIL + img2pdf |
| Template | Overlay data only | Full template image |
| Positioning | Millimeters | Pixels |
| Font Support | Unicode (₹) | Unicode (all) |

## Future Enhancements

Possible improvements:
1. Add configuration UI for position adjustment
2. Support multiple PNG templates
3. Add preview before printing
4. Support custom fonts per template
5. Add template validation on upload
