"""
advanced_analysis.py
---------------------

This script extends my analysis of the cross‑platform advertising dataset with
additional exploratory and predictive techniques.  I wrote it to build on
the foundational SQL and Python work by segmenting performance by day of
week and training a machine learning model to better understand which
features influence return on marketing investment (ROMI).

הסקריפט הזה מרחיב את הניתוח שלי לנתוני הפרסום הקרוס־פלטפורם באמצעות
טכניקות חקירה וחיזוי נוספות.  כתבתי אותו כדי להמשיך את העבודה הבסיסית
ב‑SQL וב‑Python, לבצע פילוח ביצועים לפי יום בשבוע ולאמן מודל למידת
מכונה שמסייע להבין אילו מאפיינים משפיעים על החזר ההשקעה (ROMI).
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score


def main() -> None:
    """
    Perform advanced analysis on the advertising dataset.  I compute
    day‑of‑week summaries, train a RandomForestRegressor to predict ROMI
    from multiple features, and save the resulting charts and summary files.

    פונקציה שמבצעת ניתוח מתקדם לנתוני הפרסום.  אני מחשב סיכומים לפי
    יום בשבוע, מאמן מודל Random Forest לניבוי ROMI על בסיס מספר
    מאפיינים ושומר את הגרפים ואת קבצי הסיכום.
    """

    # Load data.  I expect the CSV file to reside in the same directory
    # as this script.  To avoid issues with the working directory, I build
    # the path relative to the file location.
    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(script_dir, 'ads_data.csv')
    ads = pd.read_csv(data_path)

    # Convert date column and derive metrics per row.
    ads['date'] = pd.to_datetime(ads['date'])
    ads['CTR'] = ads['clicks'] / ads['impressions']
    ads['CPC'] = ads['cost'] / ads['clicks']
    ads['CPM'] = ads['cost'] / ads['impressions'] * 1000
    ads['ROMI'] = (ads['revenue'] - ads['cost']) / ads['cost']
    ads['day_of_week'] = ads['date'].dt.day_name()

    # Aggregate metrics by day of week and platform.  This helps me
    # understand which days are most effective for each channel.
    day_platform = ads.groupby(['day_of_week', 'platform']).agg({
        'impressions': 'sum',
        'clicks': 'sum',
        'cost': 'sum',
        'conversions': 'sum',
        'revenue': 'sum',
        'CTR': 'mean',
        'CPC': 'mean',
        'CPM': 'mean',
        'ROMI': 'mean'
    }).reset_index()

    # Ensure output directory exists.
    # Determine the images directory relative to the script.  This ensures
    # that charts are saved inside the project under ``images/``.
    images_dir = os.path.join(script_dir, 'images')
    os.makedirs(images_dir, exist_ok=True)

    # Plot average CTR by day of week and platform.  Increase figure size
    # and rotate the x‑axis labels so that weekday names are easy to read.
    plt.figure(figsize=(8, 5))
    for platform in ads['platform'].unique():
        subset = day_platform[day_platform['platform'] == platform]
        # Sort days by the natural order of the week for readability
        subset = subset.set_index('day_of_week').reindex(
            ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
        ).reset_index()
        plt.plot(subset['day_of_week'], subset['CTR'], marker='o', label=platform)
    plt.title('Average CTR by Day of Week and Platform')
    plt.xlabel('Day of Week')
    plt.ylabel('Average CTR')
    plt.legend()
    plt.xticks(rotation=45, ha='right')
    # Add a subtle grid to improve readability across weekdays.
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.savefig(os.path.join(images_dir, 'ctr_by_day_platform.png'))
    plt.close()

    # Prepare features and target for machine learning.  I include a
    # variety of predictors to capture both cost efficiency and volume.
    features = ['CTR', 'CPC', 'CPM', 'conversions', 'impressions', 'clicks']
    X = ads[features]
    y = ads['ROMI']
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Train Random Forest model.  This ensemble method captures non‑linear
    # relationships that a linear model might miss.  I chose 100 trees for
    # stability without excessive training time.
    rf = RandomForestRegressor(n_estimators=100, random_state=42)
    rf.fit(X_train, y_train)
    y_pred = rf.predict(X_test)
    r2 = r2_score(y_test, y_pred)

    # Compute and plot feature importances.  Sorting helps identify
    # the most influential variables.
    importances = pd.Series(rf.feature_importances_, index=features)
    importances = importances.sort_values(ascending=True)
    # Use a wider figure for the horizontal bar chart of feature importances.
    plt.figure(figsize=(8, 5))
    importances.plot(kind='barh')
    plt.title('Feature Importance for ROMI Prediction (Random Forest)')
    plt.xlabel('Importance')
    # Add a vertical grid to assist comparison of feature importance values.
    plt.grid(True, axis='x', linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.savefig(os.path.join(images_dir, 'romi_feature_importance.png'))
    plt.close()

    # Save day‑of‑week summary metrics and model summary to files.
    # Persist output files in the project directory.
    day_platform.to_csv(os.path.join(script_dir, 'analysis_day_platform_metrics.csv'), index=False)
    with open(os.path.join(script_dir, 'advanced_analysis_summary.txt'), 'w', encoding='utf-8') as f:
        f.write('Advanced Analysis Summary\n')
        f.write(f'Random Forest R-squared: {r2:.4f}\n\n')
        f.write('Feature Importances:\n')
        for feat, imp in importances.items():
            f.write(f'- {feat}: {imp:.4f}\n')

    print('Advanced analysis complete.  Outputs saved to files.')


if __name__ == '__main__':
    main()