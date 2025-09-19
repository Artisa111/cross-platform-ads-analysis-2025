# Cross-Platform Advertising Campaign Performance Analysis (2025)

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Project Overview
This is a data analysis project demonstrating cross-platform advertising campaign performance analysis using both SQL (PostgreSQL) and Python. The project analyzes synthetic daily data from Facebook Ads and Google Ads covering January 2024 to August 2025, calculating key performance indicators (KPIs) like CPC, CPM, CTR, and ROMI.

## Working Effectively

### Environment Setup
- **Python Version**: Project requires Python 3.8+ (validated with Python 3.12.3)
- **PostgreSQL**: Requires PostgreSQL 13+ for SQL analysis (validated with PostgreSQL 16.10)

### Essential Dependencies Installation
Run these commands in sequence - ALL are required:
```bash
# Install Python dependencies - NEVER SKIP this step
pip3 install -r requirements.txt
```
**TIMING**: Dependency installation takes 30-60 seconds. NEVER CANCEL.

### Core Dependencies (from requirements.txt):
- pandas (data manipulation)
- numpy (numerical operations)  
- matplotlib (plotting and visualization)
- scikit-learn (machine learning models)

### PostgreSQL Database Setup
```bash
# Start PostgreSQL service
sudo systemctl start postgresql

# Create database for analysis
sudo -u postgres createdb marketing

# Verify connection (should show PostgreSQL version)
sudo -u postgres psql -d marketing -c "SELECT version();" | head -3
```

### Data Loading Process
**CRITICAL**: The CSV data file MUST be loaded into PostgreSQL for SQL analysis to work:
```bash
# STEP 1: Create table structure first
sudo -u postgres psql -d marketing -f queries.sql

# STEP 2: Copy CSV to accessible location for PostgreSQL
sudo cp ads_data.csv /tmp/ads_data.csv
sudo chown postgres:postgres /tmp/ads_data.csv

# STEP 3: Load data into PostgreSQL - THIS IS REQUIRED
sudo -u postgres psql -d marketing -c "\\copy ads_data FROM '/tmp/ads_data.csv' WITH (FORMAT csv, HEADER true);"

# STEP 4: Verify data loaded correctly (should show Facebook: 609, Google: 609)
sudo -u postgres psql -d marketing -c "SELECT platform, COUNT(*) FROM ads_data GROUP BY platform;"
```
**TIMING**: Complete data setup takes 1-2 seconds total (includes table creation + 1218 rows loading). NEVER CANCEL.

### Core Analysis Execution
**ALWAYS run these commands from the project root directory:**

#### Python Analysis
```bash
# Run main analysis script - NEVER CANCEL
python3 analysis.py
```
**TIMING**: Takes 2-3 seconds. NEVER CANCEL. Set timeout to 30+ seconds.

```bash
# Run advanced analysis script - NEVER CANCEL
python3 advanced_analysis.py
```
**TIMING**: Takes 1-2 seconds. NEVER CANCEL. Set timeout to 30+ seconds.

#### SQL Analysis
```bash
# Run complete SQL analysis - NEVER CANCEL
sudo -u postgres psql -d marketing -f queries.sql
```
**TIMING**: Takes less than 1 second. NEVER CANCEL. Set timeout to 30+ seconds.

## Validation Scenarios

### ALWAYS run these validation steps after making ANY changes:

#### 1. Python Script Validation
```bash
# Test syntax compilation
python3 -m py_compile analysis.py advanced_analysis.py

# Run both analysis scripts and verify they complete successfully
python3 analysis.py && echo "Basic analysis completed successfully"
python3 advanced_analysis.py && echo "Advanced analysis completed successfully"
```

#### 2. SQL Validation
```bash
# Test database connection and data integrity
sudo -u postgres psql -d marketing -c "SELECT platform, COUNT(*) FROM ads_data GROUP BY platform;"

# Test key aggregation query works
sudo -u postgres psql -d marketing -c "SELECT COALESCE(platform, 'ALL_PLATFORMS') AS platform, SUM(impressions) AS total_impressions, SUM(clicks) AS total_clicks FROM ads_data GROUP BY GROUPING SETS (platform, ());" | head -5
```

#### 3. Output Verification
```bash
# Verify all expected output files are generated
ls -la images/*.png
ls -la analysis_summary.txt advanced_analysis_summary.txt
ls -la analysis_platform_metrics.csv analysis_day_platform_metrics.csv
```

**EXPECTED OUTPUTS**:
- `images/ctr_by_month_platform.png` (79KB)
- `images/romi_by_month_platform.png` (81KB) 
- `images/romi_prediction_scatter.png` (59KB)
- `images/ctr_by_day_platform.png` (57KB)
- `images/romi_feature_importance.png` (28KB)
- `analysis_summary.txt` (261 bytes)
- `advanced_analysis_summary.txt` (183 bytes)
- `analysis_platform_metrics.csv` (319 bytes)
- `analysis_day_platform_metrics.csv` (1.8KB)

#### 4. Manual Testing Scenarios
**ALWAYS execute these complete workflows after making changes:**

##### Scenario A: Complete Python Analysis Workflow
```bash
# 1. Install dependencies
pip3 install -r requirements.txt

# 2. Run analysis and capture timing
time python3 analysis.py

# 3. Verify outputs exist and have correct content
ls -la images/ctr_by_month_platform.png images/romi_by_month_platform.png images/romi_prediction_scatter.png
cat analysis_summary.txt | head -5
cat analysis_platform_metrics.csv
```

##### Scenario B: Complete SQL Analysis Workflow  
```bash
# 1. Setup database and load data (complete workflow)
sudo systemctl start postgresql
sudo -u postgres createdb marketing 2>/dev/null || echo "Database exists"

# 2. Create table structure and load data
sudo -u postgres psql -d marketing -f queries.sql
sudo cp ads_data.csv /tmp/ads_data.csv
sudo chown postgres:postgres /tmp/ads_data.csv
sudo -u postgres psql -d marketing -c "\\copy ads_data FROM '/tmp/ads_data.csv' WITH (FORMAT csv, HEADER true);"

# 3. Run sample queries and verify results
sudo -u postgres psql -d marketing -c "SELECT platform, AVG((clicks::NUMERIC/impressions)*100) as avg_ctr_pct FROM ads_data GROUP BY platform;"

# 4. Test key aggregation query
sudo -u postgres psql -d marketing -c "SELECT COALESCE(platform, 'ALL_PLATFORMS') AS platform, SUM(impressions) AS total_impressions, SUM(clicks) AS total_clicks FROM ads_data GROUP BY GROUPING SETS (platform, ());" | head -5
```

##### Scenario C: Complete End-to-End Workflow
```bash
# Complete workflow from fresh environment - test this after any changes
sudo systemctl start postgresql
sudo -u postgres createdb fresh_test 2>/dev/null || echo "Database ready"
pip3 install -r requirements.txt --quiet

# Setup SQL environment
sudo -u postgres psql -d fresh_test -f queries.sql
sudo cp ads_data.csv /tmp/ads_fresh.csv && sudo chown postgres:postgres /tmp/ads_fresh.csv
sudo -u postgres psql -d fresh_test -c "\\copy ads_data FROM '/tmp/ads_fresh.csv' WITH (FORMAT csv, HEADER true);"

# Run complete analysis workflow
time python3 analysis.py
time python3 advanced_analysis.py

# Verify all outputs exist
ls -la images/*.png analysis_*.txt analysis_*.csv
echo "Complete workflow test passed"
```

## Project Structure and Key Locations

### Root Directory Contents
```
├── README.md                           # Project documentation (bilingual EN/HE)
├── requirements.txt                    # Python dependencies list  
├── ads_data.csv                        # Sample dataset (1218 rows, 54KB)
├── analysis.py                         # Main Python analysis script
├── advanced_analysis.py                # Extended Python analysis script
├── queries.sql                         # PostgreSQL analysis queries
├── illustration.png                    # Project header image
├── images/                             # Generated charts and visualizations
├── analysis_summary.txt                # Basic analysis text summary
├── advanced_analysis_summary.txt       # Advanced analysis text summary
├── analysis_platform_metrics.csv      # Platform-level metrics table
└── analysis_day_platform_metrics.csv  # Day-of-week metrics table
```

### Key Scripts and Their Purpose
- **`analysis.py`**: Main analysis script that computes KPIs, generates monthly trends, and trains a linear regression model for ROMI prediction
- **`advanced_analysis.py`**: Extended analysis including day-of-week performance breakdown and Random Forest feature importance
- **`queries.sql`**: Comprehensive SQL analysis including table creation, data loading examples, and multiple aggregation queries

### Generated Outputs Location
- **Charts**: All PNG files saved to `images/` directory
- **Data Tables**: CSV files saved to project root
- **Summaries**: Text summaries saved to project root

## Troubleshooting Common Issues

### PostgreSQL Issues
```bash
# If PostgreSQL service fails to start
sudo systemctl status postgresql
sudo systemctl restart postgresql

# If database creation fails
sudo -u postgres dropdb marketing
sudo -u postgres createdb marketing

# If data loading fails due to permissions
sudo chmod 644 ads_data.csv
sudo cp ads_data.csv /tmp/ads_data.csv
sudo chown postgres:postgres /tmp/ads_data.csv
```

### Python Issues
```bash
# If imports fail, reinstall dependencies
pip3 install --upgrade -r requirements.txt

# If matplotlib display issues occur (common in headless environments)
export MPLBACKEND=Agg
python3 analysis.py
```

### Permission Issues
```bash
# If file permission errors occur
chmod +x *.py
chmod 644 *.csv *.txt *.sql
```

## Build and Test Information

### No Build Process Required
This project does not require compilation - it uses interpreted Python scripts and SQL queries.

### No Formal Test Suite
The project does not include unit tests. Validation is performed through:
1. Successful script execution
2. Output file generation verification  
3. Data integrity checks via SQL queries
4. Visual inspection of generated charts

### Linting
```bash
# Basic syntax validation
python3 -m py_compile analysis.py advanced_analysis.py

# No additional linters are configured for this project
```

## Manual Testing and Validation

### CRITICAL: Always manually test any changes you make
After making ANY modifications to the codebase, you MUST execute complete validation scenarios to ensure your changes work correctly and do not break existing functionality.

#### Required Manual Testing Steps:
1. **Clean Environment Test**: Remove all generated outputs and run the complete workflow from scratch
2. **Output Verification**: Manually inspect generated files for expected content and proper formatting
3. **Data Integrity Check**: Verify SQL queries return expected row counts and reasonable metric values
4. **Error Handling Test**: Attempt operations with missing dependencies or incorrect permissions to ensure proper error messages

#### Visual Validation of Charts
The generated PNG files should contain:
- **CTR charts**: Line charts showing Facebook (higher CTR ~3.6%) vs Google (lower CTR ~2.5%)
- **ROMI charts**: Line charts showing Facebook (generally higher ROMI 8-11) vs Google (lower ROMI 5-7)
- **Scatter plot**: Model prediction accuracy visualization with points along diagonal line (R² ≈ 0.60)
- **Feature importance**: Bar chart showing cost, clicks, impressions impact on ROMI prediction

## Performance Expectations

### Timing Benchmarks (Validated)
- **Python dependency installation**: 30-60 seconds
- **PostgreSQL data loading**: <1 second (1218 rows)
- **analysis.py execution**: 2-3 seconds
- **advanced_analysis.py execution**: 1-2 seconds  
- **SQL queries execution**: <1 second
- **Complete workflow (Python + SQL)**: <10 seconds total

### Resource Requirements
- **Disk Space**: <200MB total (including dependencies)
- **Memory**: <500MB during execution
- **CPU**: Single-threaded, minimal requirements

## Common Development Tasks

### Adding New Analysis Features
1. **For Python analysis**: Modify `analysis.py` or `advanced_analysis.py`
2. **For SQL analysis**: Add queries to `queries.sql`
3. **Always test both**: Run validation scenarios after changes
4. **Update documentation**: If adding new outputs or requirements

### Modifying Data Sources
1. **CSV format**: Must match existing schema (date, platform, impressions, clicks, cost, conversions, revenue)
2. **SQL schema**: Defined in `queries.sql` lines 43-51
3. **Python assumptions**: Scripts expect CSV in same directory

### Chart Customization
- **Matplotlib settings**: Configured in analysis scripts
- **Output location**: All charts saved to `images/` directory
- **File formats**: PNG format, various sizes (28KB-81KB typical)

## Dependencies Summary
- **Python**: 3.8+ required, 3.12.3 validated
- **PostgreSQL**: 13+ required, 16.10 validated
- **OS**: Linux (Ubuntu validated), should work on macOS/Windows with minor path adjustments
- **Libraries**: pandas, numpy, matplotlib, scikit-learn (all versions auto-selected by pip)