# Font Size Control Guide

## Quick Reference

### Available Font Sizes

| Font Variable | Size (pixels) | Use Case |
|--------------|---------------|----------|
| `font_large` | 14 | Prominent text (headings, important numbers) |
| `font_regular` | 12 | Normal text (default for most fields) |
| `font_medium` | 11 | Slightly smaller text |
| `font_small` | 10 | Secondary information (labels, agents) |
| `font_tiny` | 8 | Very small text (fine print) |

## How to Change Font Size for Each Element

Edit: [forex_contracts.py:975](forex/forex/doctype/forex_contracts/forex_contracts.py#L975)

### Current Configuration

```python
text_config = {
    # Header Fields
    'time': {'pos': (700, 58), 'font': font_regular},      # Contract time
    'number': {'pos': (700, 105), 'font': font_regular},   # Contract number
    'date': {'pos': (700, 153), 'font': font_regular},     # Contract date

    # Party Information
    'seller_name': {'pos': (150, 195), 'font': font_regular},   # Seller bank name
    'seller_agent': {'pos': (150, 215), 'font': font_small},    # Seller agent
    'buyer_name': {'pos': (150, 260), 'font': font_regular},    # Buyer bank name
    'buyer_agent': {'pos': (150, 280), 'font': font_small},     # Buyer agent

    # Transaction Details
    'amount': {'pos': (24, 342), 'font': font_regular},        # USD amount
    'currency': {'pos': (224, 342), 'font': font_regular},     # Currency (USD)
    'usance': {'pos': (336, 395), 'font': font_small},         # Usance (T.T)
    'against': {'pos': (336, 415), 'font': font_small},        # Against (USD)
    'payable': {'pos': (336, 433), 'font': font_small},        # Payable (INR)
    'rate': {'pos': (428, 342), 'font': font_regular},         # Exchange rate
    'delivery': {'pos': (562, 342), 'font': font_regular},     # Delivery date
    'fund_type': {'pos': (562, 420), 'font': font_small},      # Fund location
}
```

## Common Adjustments

### Make Contract Number Larger and Bold
```python
# First, create a bold font variant (add after line 924)
font_large_bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)

# Then use it in the config
'number': {'pos': (700, 105), 'font': font_large_bold},
```

### Make All Header Fields Larger
```python
'time': {'pos': (700, 58), 'font': font_large},
'number': {'pos': (700, 105), 'font': font_large},
'date': {'pos': (700, 153), 'font': font_large},
```

### Make Amount More Prominent
```python
'amount': {'pos': (24, 342), 'font': font_large},
```

### Make Agent Information Smaller
```python
'seller_agent': {'pos': (150, 215), 'font': font_tiny},
'buyer_agent': {'pos': (150, 280), 'font': font_tiny},
```

## Creating Custom Font Sizes

### Adding a New Font Size

Add to the font loading section (around line 924):

```python
try:
    font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
    font_regular = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
    font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 11)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 10)
    font_tiny = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 8)

    # YOUR CUSTOM FONTS
    font_huge = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
    font_xs = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 9)
except:
    # Also add fallbacks
    font_huge = ImageFont.load_default()
    font_xs = ImageFont.load_default()
```

### Using Bold Fonts

```python
# Regular bold
font_bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 12)

# Large bold
font_large_bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)

# Use in config
'number': {'pos': (700, 105), 'font': font_bold},
'amount': {'pos': (24, 342), 'font': font_large_bold},
```

## Testing Your Changes

1. Edit the configuration in [forex_contracts.py](forex/forex/doctype/forex_contracts/forex_contracts.py)
2. Save the file
3. Restart the bench: `bench restart`
4. Select a test contract in the list view
5. Click "Print on PNG"
6. Review the generated PDF
7. Adjust as needed

## Tips for Font Size Selection

- **Headers (Time, Number, Date)**: Use `font_regular` or `font_large` for visibility
- **Party Names**: Use `font_regular` for readability
- **Agent Info**: Use `font_small` or `font_tiny` as it's less important
- **Transaction Amounts**: Use `font_regular` or `font_large` for prominence
- **Labels and Codes**: Use `font_small` for compact display
- **Legal Text**: Use `font_tiny` for fine print

## Troubleshooting

### Font looks too small/large
- Adjust the font size number in the `ImageFont.truetype()` call
- Remember: larger number = larger text

### Font not loading
- Verify the font path exists: `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf`
- Check for typos in the font filename
- The system will fall back to default font if not found

### Text getting cut off
- If text is too large, it might overflow the designated space
- Either reduce font size or adjust position to give more space
- Consider using a narrower font variant

### Different fonts on two copies
- Each contract generates 2 separate pages (Near Leg and Far Leg)
- Both copies use the same PNG template and identical font configuration
- No position offsets needed - each copy is on a fresh PNG template
- **Important**: In Far Leg (page 2), seller and buyer are automatically swapped (seller becomes buyer, buyer becomes seller, and their agents are also swapped)
