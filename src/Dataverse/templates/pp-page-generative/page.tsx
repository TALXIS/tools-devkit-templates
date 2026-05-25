import { useEffect, useState } from 'react';
import {
  makeStyles,
  Title1,
  Card,
  CardHeader,
  Text,
  Spinner,
  tokens
} from '@fluentui/react-components';
import type { GeneratedComponentProps } from './RuntimeTypes';

const useStyles = makeStyles({
  container: {
    display: 'flex',
    flexDirection: 'column',
    gap: tokens.spacingVerticalL,
    padding: tokens.spacingHorizontalXL,
  },
});

const GeneratedComponent = (props: GeneratedComponentProps) => {
  const { dataApi, pageInput } = props;
  const styles = useStyles();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  if (loading) {
    return <Spinner label="Loading..." />;
  }

  return (
    <div className={styles.container}>
      <Title1>genpageexampleDisplayName</Title1>
      <Card>
        <CardHeader header={<Text weight="semibold">Getting Started</Text>} />
        <Text>Edit page.tsx to build your generative page. Use props.dataApi for Dataverse CRUD operations.</Text>
      </Card>
    </div>
  );
};

export default GeneratedComponent;
