"""
analysis.py
---------------

This script performs advanced analysis of the cross‑platform advertising dataset
used in this project.  I wrote it to complement the SQL analysis by exploring
the data in Python, generating visualisations and building a simple predictive
model.  Running this script will compute additional metrics, aggregate them by
platform and month, train a linear regression model to predict return on
marketing investment (ROMI), and save the resulting charts into the
``images/`` folder.

הקובץ הזה הוא סקריפט ניתוח מתקדם לנתוני פרסום קרוס־פלטפורם.
אני כתבתי אותו כדי להשלים את הניתוח ב‑SQL ולחקור את הנתונים גם ב‑Python,
לייצר ויזואליזציות ולבנות מודל ניבוי פשוט.  הריצה של הסקריפט תחשב
מדדים נוספים, תאגד אותם לפי פלטפורמה וחודש, תבנה מודל רגרסיה ליניארית
לחיזוי ROMI ותשמור את הגרפים בתיקייה ``images/``.
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score


def main():
    """
    Main analysis function.  Loads the CSV file, computes metrics, aggregates
    by platform and month, trains a regression model to predict ROMI and
    writes summary outputs and charts to disk.

    פונקציית הניתוח הראשית.  היא טוענת את קובץ ה‑CSV, מחשבת מדדים,
    מאגדת לפי פלטפורמה וחודש, מאמנת מודל רגרסיה לחיזוי ROMI
    וכותבת את הסיכום והגרפים לקבצים.
    """

    # Load the dataset.  I assume that ``ads_data.csv`` is in the same
    # directory as this script.  If not, adjust the path accordingly.
    ads = pd.read_csv('ads_data.csv')

    # Compute additional performance metrics per row.  I calculate CTR,
    # CPC, CPM and ROMI for each record so that they can be aggregated later.
    ads['CTR'] = ads['clicks'] / ads['impressions']
    ads['CPC'] = ads['cost'] / ads['clicks']
    ads['CPM'] = ads['cost'] / ads['impressions'] * 1000
    ads['ROMI'] = (ads['revenue'] - ads['cost']) / ads['cost']

    # Convert the date column to a proper datetime and derive a month key.
    ads['date'] = pd.to_datetime(ads['date'])
    ads['month'] = ads['date'].dt.to_period('M').dt.to_timestamp()

    # Aggregate metrics by platform.  This summarises the overall performance
    # of each channel across the full dataset.  I sum the base columns and
    # derive the same KPIs as above.
    group_platform = ads.groupby('platform').agg({
        'impressions': 'sum',
        'clicks': 'sum',
        'cost': 'sum',
        'revenue': 'sum',
        'conversions': 'sum'
    })
    group_platform['CTR'] = group_platform['clicks'] / group_platform['impressions']
    group_platform['CPC'] = group_platform['cost'] / group_platform['clicks']
    group_platform['CPM'] = group_platform['cost'] / group_platform['impressions'] * 1000
    group_platform['ROMI'] = (group_platform['revenue'] - group_platform['cost']) / group_platform['cost']

    # Aggregate metrics by month and platform for trend analysis.
    monthly = ads.groupby(['month', 'platform']).agg({
        'impressions': 'sum',
        'clicks': 'sum',
        'cost': 'sum',
        'revenue': 'sum',
        'conversions': 'sum'
    }).reset_index()
    monthly['CTR'] = monthly['clicks'] / monthly['impressions']
    monthly['CPC'] = monthly['cost'] / monthly['clicks']
    monthly['CPM'] = monthly['cost'] / monthly['impressions'] * 1000
    monthly['ROMI'] = (monthly['revenue'] - monthly['cost']) / monthly['cost']

    # Prepare output directories.
    images_dir = 'images'
    os.makedirs(images_dir, exist_ok=True)

    # Plot CTR by month and platform.
    plt.figure()
    for platform in monthly['platform'].unique():
        subset = monthly[monthly['platform'] == platform]
        plt.plot(subset['month'], subset['CTR'], label=platform)
    plt.title('CTR by Month and Platform')
    plt.xlabel('Month')
    plt.ylabel('CTR')
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(images_dir, 'ctr_by_month_platform.png'))
    plt.close()

    # Plot ROMI by month and platform.
    plt.figure()
    for platform in monthly['platform'].unique():
        subset = monthly[monthly['platform'] == platform]
        plt.plot(subset['month'], subset['ROMI'], label=platform)
    plt.title('ROMI by Month and Platform')
    plt.xlabel('Month')
    plt.ylabel('ROMI')
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(images_dir, 'romi_by_month_platform.png'))
    plt.close()

    # Build a linear regression model to predict ROMI from impressions, clicks, cost and conversions.
    features = ads[['impressions', 'clicks', 'cost', 'conversions']]
    target = ads['ROMI']
    X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.3, random_state=42)
    model = LinearRegression()
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    r2 = r2_score(y_test, y_pred)

    # Plot predicted vs actual ROMI to visualise model performance.
    plt.figure()
    plt.scatter(y_test, y_pred, alpha=0.5)
    plt.xlabel('Actual ROMI')
    plt.ylabel('Predicted ROMI')
    plt.title('Predicted vs Actual ROMI (Linear Regression)')
    plt.tight_layout()
    plt.savefig(os.path.join(images_dir, 'romi_prediction_scatter.png'))
    plt.close()

    # Save aggregated metrics and model summary to files.
    group_platform.to_csv('analysis_platform_metrics.csv')
    with open('analysis_summary.txt', 'w', encoding='utf-8') as f:
        f.write('Aggregated metrics by platform:\n')
        f.write(group_platform[['CTR', 'CPC', 'CPM', 'ROMI']].to_string())
        f.write('\n\nLinear Regression R-squared: {:.4f}\n'.format(r2))

    print('Analysis complete.  Summary and charts saved.')


if __name__ == '__main__':
    main()