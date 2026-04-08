# Looker Studio Product Attributes Dashboard Guide

Since you've successfully built the main "Global Retail Health" dashboard, this guide will walk you through adding the new Phase 4 charts into Looker Studio. These charts use the newly created `mart_product_attributes_performance` table to dive deeper into product-level merchandising questions.

## Step 1: Understand Your Fields & Prepare Data Types (Crucial!)

Before building charts, Looker Studio needs to know the difference between a **Dimension** (text labels used to group your data, like "Brand") and a **Metric** (the actual numbers you are measuring, like "Total Items"). 

Import your newly generated `mart_product_attributes_performance` data source into Looker Studio. Click **Resource** -> **Manage added data sources**, and click **Edit**. Ensure your fields are configured as follows:

### 🔷 Dimensions (Keep Type as Text)
These fields are used to slice and dice your charts:
* **`market`**: The country where the products are sold. → *Change Type to **Geo → Country** so map charts work.*
* **`brand_name`**: The primary label of the item (e.g., Nike, Jordan, Converse).
* **`subcategory`**: The specific product type (e.g., Running Shoes, Hoodies).
* **`sport_category`**: Clustered activity category derived from raw sport tags (e.g., Lifestyle, Running, Training & Gym, Soccer & Football, Racquet Sports, Outdoor, Other Sports).
* **`color_trend`**: Classifies if the item's primary color is a basic **Core** (Black/White/Grey in any language) or a **Seasonal** variation (colored/fashion-forward).

### 🔢 Metrics (Change Type to Numeric formats)
These are the numeric values you plot. When adding these to a chart, Looker uses an "Aggregation" (how it summarizes the math, usually Sum or Average).
* **`sku_count`**: The total selection size. **Meaning:** How many unique products/variations you offer in this group. → *Default Aggregation: **Sum***.
* **`avg_price`**: The original sticker price. **Meaning:** The average label price before any sales. → *Change Type to **Currency**. Chart Aggregation: **Average***.
* **`avg_markdown_pct`**: The discount depth. **Meaning:** When items go on sale, how big is the price cut on average? → *Change Type to **Numeric → Percent**. Chart Aggregation: **Average***.
* **`promo_penetration_pct`**: The share on sale. **Meaning:** What percentage of this category currently has a discount? → *Change Type to **Numeric → Percent**. Chart Aggregation: **Average***.
* **`oos_rate_pct`**: Out-of-Stock rate. **Meaning:** What percentage of these items are completely sold out? → *Change Type to **Numeric → Percent**. Chart Aggregation: **Average***.
* **`full_price_sell_through_pct`**: Full price health. **Meaning:** What percentage of these items are being sold at full retail price with no discount? → *Change Type to **Numeric → Percent**. Chart Aggregation: **Average***.

---

## Step 2: Dashboard Layout Expansion

If you are adding to your existing report, it is best to **Add a Page** or scroll down to create a new section dedicated to **"Product & Merchandising Details"**. 

* Add a global filter at the top: Click **Add a control** → **Drop-down list**.
* Set it to **`market`** using the new data source so it can filter the charts below.

---

## Step 3: Build the New Charts

Follow these steps to construct the 4 new charts answering your detailed merchandising questions.

### Chart 5: Brand Equity & Discount Strategy
* **Goal**: Answer "Do premium brands protect their cachet better?" by exploring if certain brands avoid heavy discounts.
* **Steps**: 
  1. **Add a chart** → **Bar chart**.
  2. **Data Source**: `mart_product_attributes_performance`.
  3. **Dimension**: `brand_name` (Groups your data into bars per brand).
  4. **Metrics**: 
     - Add `avg_markdown_pct` (Click the mini-pencil icon and ensure Aggregation is set to **Average**).
     - Add `promo_penetration_pct` (Ensure Aggregation is **Average**).
  5. **Sort**: By `avg_markdown_pct` **Descending**.
  > [!TIP]
  > This chart contrasts *how often* a brand is on sale (`promo_penetration_pct`) against *how deep* the cut is (`avg_markdown_pct`).

### Chart 6: Lifestyle vs Performance Pricing
* **Goal**: Answer "Is performance gear discounted heavier than Lifestyle footwear/apparel?"
* **Steps**:
  1. **Add a chart** → **Bar chart** (Grouped side-by-side or Horizontal).
  2. **Data Source**: `mart_product_attributes_performance`.
  3. **Dimension**: `sport_category` (Groups your data by the clustered activity category).
  4. **Metrics**: 
     - Add `avg_price` (Ensure Aggregation is **Average**). Use the left Y-axis.
     - Add `promo_penetration_pct` (Ensure Aggregation is **Average**). Use the right Y-axis.
  5. *Styling*: Go to the Style tab and change the second metric (`promo_penetration_pct`) to a Line or switch the axis to the right side so the currency and percentages don't squash each other.

### Chart 7: Micro-Merchandising Stock Health
* **Goal**: Answer "Which subcategories are driving Out-of-Stock (OOS) rates?"
* **Steps**:
  1. **Add a chart** → **Scatter chart**.
  2. **Data Source**: `mart_product_attributes_performance`.
  3. **Dimension**: `subcategory` (Each dot represents a specific product subtype).
  4. **Metric X**: `sku_count` (Ensure Aggregation is **Sum**). This plots the total selection size horizontally.
  5. **Metric Y**: `oos_rate_pct` (Ensure Aggregation is **Average**). This plots the stockout risk vertically.
  6. **Bubble Size**: Add `sku_count` again to make dots larger for bigger categories.
  > [!NOTE]
  > Subcategories plotting high on the Y-axis and far right on the X-axis represent a large chunk of your catalog that is frequently running out of stock!

### Chart 8: Core vs. Seasonal Color Trends
* **Goal**: Answer "Are 'wild' colorways a liability requiring heavier discounts?"
* **Steps**:
  1. **Add a chart** → **Donut chart**.
  2. **Data Source**: `mart_product_attributes_performance`.
  3. **Dimension**: `color_trend` (Splits the donut into 'Core' vs 'Seasonal' slices).
  4. **Metric**: Add `sku_count` (Aggregation = **Sum**). This shows the strict volume split between colors.
  5. **Second Chart**: Create a second identical Donut chart right next to it, but change the Metric to `avg_markdown_pct` (Aggregation = **Average**). 
  > [!TIP]
  > Having one donut showing volume (`sku_count`) and the other showing the average discount (`avg_markdown_pct`) visually highlights if seasonal colors generate disproportionate markdowns compared to core colors.

---

## Step 4: Final Polish (Interactivity)

1. **Cross-Filtering**: Ensure you check the **Cross-filtering** box at the bottom of the Setup tab for your Bar Charts and Donut Charts. Clicking on a specific `brand_name` (e.g., Jordan) will instantly filter the Scatter Plot to show those specific subcategories' stock out rates.
2. **Page-Level Controls**: Add additional dropdown filters for `gender` and `category` (Dimensions) linked to this new mart to give your users detailed slicing capabilities!
