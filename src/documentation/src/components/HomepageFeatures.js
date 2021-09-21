import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Easy to Use',
    Svg: require('../../static/img/easy.svg').default,
    description: (
      <>
        ActNow was designed from the ground up to be easily installed and used to connect with
        people around you.
      </>
    ),
  },
  {
    title: 'Focus on What Matters',
    Svg: require('../../static/img/focus.svg').default,
    description: (
      <>
        Unlike other platforms, we want you to use ActNow less. Our goal is to put down the app and
        meet other people outside.
      </>
    ),
  },
  {
    title: 'Powered by Flutter',
    Svg: require('../../static/img/phone.svg').default,
    description: (
      <>ActNow is built using the most cutting-edge software, so it will never fell outdated.</>
    ),
  },
];

function Feature({ Svg, title, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
